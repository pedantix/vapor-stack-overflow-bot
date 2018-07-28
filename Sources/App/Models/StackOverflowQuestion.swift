import FluentPostgreSQL
import Vapor

/// A single entry of a Todo list.
final class StackOverflowQuestion: PostgreSQLModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    let questionId: Int
    let link: String

    /// Creates a new `Todo`.
    init(id: Int? = nil, questionId: Int, link: String) {
        self.id = id
        self.questionId = questionId
        self.link = link
    }

    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case link
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension StackOverflowQuestion: Migration {
    static func prepare(on conn: PostgreSQLConnection) -> Future<Void> {
        return Database.create(StackOverflowQuestion.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.questionId)
            builder.field(for: \.link)
            builder.unique(on: \.questionId)
        }
    }
}

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension StackOverflowQuestion: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension StackOverflowQuestion: Parameter { }
