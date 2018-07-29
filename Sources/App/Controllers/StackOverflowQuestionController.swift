import Vapor

/// Controls basic CRUD operations on `Todo`s.
final class StackOverflowQuestionController {
    /// Returns a list of all `StackOverflowQuestion`s.
    func index(_ req: Request) throws -> Future<[StackOverflowQuestion]> {
        return StackOverflowQuestion.query(on: req).all()
    }

    // TODO: Remove me
    func newStackOverflowQuestions(_ req: Request) throws -> Future<[StackOverflowQuestion]> {
        let newRequestObj = try req.make(StackOverflowService.self)
        return newRequestObj.getNewStackOverflowQuestions(tag: "vapor")
    }
}
