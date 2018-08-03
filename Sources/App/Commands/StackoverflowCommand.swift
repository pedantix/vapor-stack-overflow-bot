import Vapor
import FluentPostgreSQL

final class StackoverflowCommand: Command {
    var arguments: [CommandArgument] {
        return [
            .argument(
                name: "tags",
                help: ["a comma seperated list of tags to query stackoverflow with"]
            )
        ]
    }
    var options: [CommandOption] = []
    var help: [String] {
        return [
            "Queries the stackoverflow API with supplied tags(comma seperated) and posts new questions to a webhook"
        ]
    }

    func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let tagReqs = try context.argument("tags").split(separator: ",").map { tag in
            try queryForTag(tag: "\(tag)", context: context)
        }
        return tagReqs.flatten(on: context.container)
    }

    func queryForTag(
        tag: String,
        context: CommandContext
    ) throws -> EventLoopFuture<Void> {
        let newRequestObj = try context.container.make(StackOverflowService.self)
        return newRequestObj.getNewStackOverflowQuestions(tag: tag).flatMap { questions in
           return try self.postNewQuestions(questions, context: context)
        }
    }


    private func postNewQuestions(_ newQuestions: [StackOverflowQuestion], context: CommandContext) throws -> EventLoopFuture<Void> {
        let webhookService = try context.container.make(DiscordWebhookService.self)
        var questions = newQuestions
        guard let postingQuestion = questions.popLast()
            else { return .done(on:context.container) }
        return try webhookService.postContent(postingQuestion.link).flatMap { _ in
            return try self.postNewQuestions(questions, context: context).catchFlatMap { err in
                if let err = err as? DiscordError {
                    return self.deleteUnpostedQuestion(err.link, context: context)
                }
                return .done(on: context.container)
            }
        }
    }

    private func deleteUnpostedQuestion(_ link: String, context: CommandContext) -> Future<Void>{
        return context.container.withPooledConnection(to: .psql) { (conn) -> EventLoopFuture<Void> in
             return StackOverflowQuestion.query(on: conn).filter(\.link == link).delete()
        }
    }
}
