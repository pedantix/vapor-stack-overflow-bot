import Vapor

// Read more about discord webhooks here
// https://discordapp.com/developers/docs/resources/webhook#execute-webhook
struct DiscordWebhookService: Service {
    let client: Client
    let webhookUrl: String
    let logger: Logger
    let jsonEncoder: DataEncoder

    func postContent(_ content: String) throws -> Future<Void> {
        let content = DiscordWebhookPayload(content: content)
        return client.post(webhookUrl, headers: HTTPHeaders()) { (req) in
            req.http.body = try jsonEncoder.encode(content).convertToHTTPBody()
        }.map(to: Void.self) { _ in
            self.logger.info("Posted: \(content) response")
        }
    }
}

extension DiscordWebhookService: ServiceType {

    static func makeService(for worker: Container) throws -> DiscordWebhookService {
        let jsonEncoder = try worker.make(ContentCoders.self).requireDataEncoder(for: .json)

        return try .init(
            client: worker.make(),
            webhookUrl: worker.make(DiscordWebhookServiceConfig.self).webhookUrl,
            logger: worker.make(),
            jsonEncoder: jsonEncoder
        )
    }
}

struct DiscordWebhookServiceConfig: Service {
    let webhookUrl: String
}

private struct DiscordWebhookPayload: Content {
    let content: String
}
