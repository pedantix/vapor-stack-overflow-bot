import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: StackOverflowQuestion.self, database: .psql)
    services.register(migrations)

    configureDatabase(&services)

    services.register(StackOverflowUrlService.self)

    guard let webhookUrl = ProcessInfo.processInfo.environment["WEBHOOK_URL"]
        else { fatalError("No Webhook URL") }

    let discordWebhookServiceConfig = DiscordWebhookServiceConfig(webhookUrl: webhookUrl)
    services.register(discordWebhookServiceConfig)
    services.register(DiscordWebhookService.self)
    var commandConfig = CommandConfig.default()
    commandConfig.use(StackoverflowCommand(), as: "stackoverflow")

    services.register(commandConfig)
}

private func configureDatabase(_ services: inout Services) {
    let databaseConfig: PostgreSQLDatabaseConfig
    if let databaseUrl = ProcessInfo.processInfo.environment["DATABASE_URL"],
        let config = PostgreSQLDatabaseConfig(url: databaseUrl) {
        databaseConfig = config
    } else {
        let databaseHostname = ProcessInfo.processInfo.environment["DATABASE_HOSTNAME"] ?? "localhost"
        let databasePort = Int(ProcessInfo.processInfo.environment["DATABASE_PORT"] ?? "") ??  5432
        let databaseUsername = ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ??  "shaunhubbard"

        let databasePassword = ProcessInfo.processInfo.environment["DATABASE_PASSWORD"]
        let databaseName = ProcessInfo.processInfo.environment["DATABASE_NAME"] ??  "vapor_stack_overflow_bot_db"
        databaseConfig = PostgreSQLDatabaseConfig(hostname: databaseHostname,
                                                  port: databasePort,
                                                  username: databaseUsername,
                                                  database: databaseName,
                                                  password: databasePassword)
    }

    let database = PostgreSQLDatabase(config: databaseConfig)
    var databasesConfig = DatabasesConfig()
    databasesConfig.add(database: database,
                        as: .psql)

    //databasesConfig.enableLogging(on: .psql)
    services.register(databasesConfig)
    services.register(StackOverflowUrlService.self)
    services.register(StackOverflowService.self)
}
