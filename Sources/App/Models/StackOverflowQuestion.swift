import FluentPostgreSQL
import Vapor

/// A single entry of a StackOverflowQuestion list.
final class StackOverflowQuestion: PostgreSQLModel {
    /// The unique identifier for this `StackOverflowQuestion`.
    var id: Int?
    var createdAt: Date?

    /// A title describing what this `StackOverflowQuestion` entails.
    let questionId: Int
    let link: String

    /// Creates a new `StackOverflowQuestion`.
    init(id: Int? = nil, questionId: Int, link: String) {
        self.id = id
        self.questionId = questionId
        self.link = link
    }

    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case link
        case createdAt
    }

    static var createdAtKey: TimestampKey? = \.createdAt
}

/// Allows `Todo` to be used as a dynamic migration.
extension StackOverflowQuestion: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(StackOverflowQuestion.self, on: conn) { builder in
            try addProperties(to: builder)
            builder.unique(on: \.questionId)
        }
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension StackOverflowQuestion: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension StackOverflowQuestion: Parameter { }
