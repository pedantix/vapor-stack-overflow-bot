import Vapor
import Foundation
import FluentPostgreSQL
import Fluent

private typealias Questions = [StackOverflowQuestion]

struct StackOverflowService: Service {
    let client: Client
    let stackOverflowUrlService: StackOverflowUrlService
    let decoder: DataDecoder
    let connectionPool: DatabaseConnectionPool<ConfiguredDatabase<PostgreSQLDatabase>>

    func getNewStackOverflowQuestions(tag: String) -> Future<[StackOverflowQuestion]> {
        return connectionPool.withConnection { connection in
            self.getQuestions(tag: tag, on: connection)
        }
    }

    private func getQuestions(tag: String, on connection: PostgreSQLConnection) -> EventLoopFuture<Questions> {
        return self.getNewQuestionsFromStackOverflow(tag: tag)
            .flatMap { questionsFromClient in
                let foundQuestionIds = questionsFromClient.map { $0.questionId }
                return self.matchingQuestions(foundQuestionIds, connection: connection)
                    .flatMap({ questionsFromDatabase in
                        return self.filterForNewQuestionsAndPersist(
                            questionsFromDatabase: questionsFromDatabase,
                            questionsFromClient: questionsFromClient,
                            connection: connection
                        )
                    })

        }
    }

    private func getNewQuestionsFromStackOverflow(tag: String) -> EventLoopFuture<Questions> {
        let url = stackOverflowUrlService.requestForQuestions(for: tag)
        return client
            .get(url)
            .map(to: [StackOverflowQuestion].self, self.decodeResponseData)
    }

    private func decodeResponseData(_ response: Response) throws -> Questions {
        let data = response.http.body.data ?? Data()
        return try self.decoder.decode(StackOverflowQuestionContainer.self,
                                       from: data).items
    }

    private func matchingQuestions(
        _ foundQuestionIds: [Int],
        connection: PostgreSQLConnection
    ) -> EventLoopFuture<Questions> {
        return StackOverflowQuestion
            .query(on: connection)
            .filter(\.questionId ~~ foundQuestionIds)
            .all()
    }

    private func filterForNewQuestionsAndPersist(
        questionsFromDatabase: Questions,
        questionsFromClient: Questions,
        connection: PostgreSQLConnection
    ) -> EventLoopFuture<Questions> {
        let foundQuestionIds = questionsFromClient.map { $0.questionId }
        let dbQuestionIds = questionsFromDatabase.map { $0.questionId }
        let unsavedQuestions = Set(foundQuestionIds).subtracting(Set(dbQuestionIds))
        return questionsFromClient
            .filter { question in unsavedQuestions.contains(question.questionId) }
            .map { question -> Future<StackOverflowQuestion>  in
                return question.save(on: connection)
        }.flatten(on: connection)
    }
}

extension StackOverflowService: ServiceType {
    static func makeService(for worker: Container) throws -> StackOverflowService {
        let jsonDecoder = try worker.make(ContentCoders.self).requireDataDecoder(for: .json)
        let connectionPool = try worker.connectionPool(to: .psql)
        return try StackOverflowService(client: worker.make(),
                                        stackOverflowUrlService: worker.make(),
                                        decoder: jsonDecoder,
                                        connectionPool: connectionPool)
    }
}

struct StackOverflowQuestionContainer: Codable {
    let items: [StackOverflowQuestion]
}
