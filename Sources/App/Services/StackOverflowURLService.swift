import Vapor
struct StackOverflowUrlService: Service {
    let baseUrlString = "https://api.stackexchange.com/2.2/questions?order=desc&site=stackoverflow&sort=creation"

    func requestForQuestions(
        for tag: String
    ) -> URLRepresentable {
        return baseUrlString + "&tagged=\(tag)"
    }
}

extension StackOverflowUrlService: ServiceType {
    static func makeService(for worker: Container) throws -> StackOverflowUrlService {
        return .init()
    }
}
