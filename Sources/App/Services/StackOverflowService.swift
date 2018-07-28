import Vapor
import Foundation
import FluentPostgreSQL
import Fluent

struct StackOverflowService: Service {
    let client: Client
    let stackOverflowUrlService: StackOverflowUrlService
    let decoder: DataDecoder

    func getNewStackOverflowQuestions(tag: String, req: Request) -> Future<[StackOverflowQuestion]> {
        let url = stackOverflowUrlService.requestForQuestions(for: "vapor", timeAgo: 6 * 60 * 60)
        return client
            .get(url)
            .map(to: [StackOverflowQuestion].self) { response in
            let data = response.http.body.data ?? Data()
            return try self.decoder.decode(StackOverflowQuestionContainer.self,
                                            from: data).items
        }.flatMap { questionsFromClient in
            let foundQuestionIds = questionsFromClient.map { $0.questionId }
            return StackOverflowQuestion
                .query(on: req)
                .filter(\.questionId ~~ foundQuestionIds)
                .all()
                .map({ questionsFromDatabase in
                    let dbQuestionIds = questionsFromDatabase.map { $0.questionId }
                    var sb = Set(foundQuestionIds)
                    sb.subtract(Set(dbQuestionIds))
                    return questionsFromClient
                        .filter { question in sb.contains(question.questionId) }
                        .map {
                            _ = $0.save(on: req)
                            return $0
                    }
            })

        }
    }
}

extension StackOverflowService: ServiceType {
    static func makeService(for worker: Container) throws -> StackOverflowService {
        let jsonDecoder = try worker.make(ContentCoders.self).requireDataDecoder(for: .json)
        return try StackOverflowService(client: worker.make(),
                                        stackOverflowUrlService: worker.make(),
                                        decoder: jsonDecoder)
    }
}

struct StackOverflowQuestionContainer: Codable {
    let items: [StackOverflowQuestion]
}
