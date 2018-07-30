import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class StackOverflowQuestionController {
    /// Returns a list of all `StackOverflowQuestion`s.
    func index(_ req: Request) throws -> Future<[StackOverflowQuestion]> {
        return StackOverflowQuestion.query(on: req).all()
    }
}
