import Vapor
import Foundation
import FluentPostgreSQL
import Fluent

private typealias Questions = [StackOverflowQuestion]

struct StackOverflowService: Service {
    let client: Client
    let stackOverflowUrlService: StackOverflowUrlService
    let connectionPool: DatabaseConnectionPool<ConfiguredDatabase<PostgreSQLDatabase>>

    func getNewStackOverflowQuestions(tag: String) -> Future<[StackOverflowQuestion]> {
        return connectionPool.withConnection { connection in
            self.getQuestions(tag: tag, on: connection)
        }
    }

    private func getQuestions(tag: String, on connection: PostgreSQLConnection) -> EventLoopFuture<Questions> {
        return self.getNewQuestionsFromStackOverflow(tag: tag)
            .flatMap { questions in
                let newQuestions = questions.map { question -> Future<StackOverflowQuestion?> in
                    question.save(on: connection)
                        .map { .some($0) }
                        .catchMap { error in
                            // Silence unique index violation errors
                            guard let pgError = error as? PostgreSQLError, pgError.identifier == "server.error._bt_check_unique" else {
                                throw error
                            }

                            return nil
                        }
                }

                return EventLoopFuture<Questions>.reduce(into: [], newQuestions, eventLoop: connection.eventLoop, { (acc, question) in
                    guard let question = question else {
                        return
                    }

                    acc.append(question)
                })
            }
    }

    private func getNewQuestionsFromStackOverflow(tag: String) -> EventLoopFuture<Questions> {
        let url = stackOverflowUrlService.requestForQuestions(for: tag)
        return client
            .get(url)
            .flatMap { try $0.content.decode(ListWrapper<StackOverflowQuestion>.self) }
            .map { $0.items }
    }
}

extension StackOverflowService: ServiceType {
    static func makeService(for worker: Container) throws -> StackOverflowService {
        let connectionPool = try worker.connectionPool(to: .psql)
        return try StackOverflowService(client: worker.make(),
                                        stackOverflowUrlService: worker.make(),
                                        connectionPool: connectionPool)
    }
}

private struct ListWrapper<T: Decodable>: Decodable {
    let items: [T]
}
