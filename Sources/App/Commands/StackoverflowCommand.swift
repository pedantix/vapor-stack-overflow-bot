import Vapor

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
        let webhookService = try context.container.make(DiscordWebhookService.self)
        return newRequestObj.getNewStackOverflowQuestions(tag: "vapor").map { questions in

            try questions.forEach {
                _ = try webhookService.postContent($0.link)
            }
        }
    }
}
