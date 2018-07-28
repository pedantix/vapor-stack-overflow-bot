import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

    // Example of configuring a controller
    let questionController = StackOverflowQuestionController()
    router.get("questions", use: questionController.index)
    router.get("new-questions", use: questionController.newStackOverflowQuestions)
}
