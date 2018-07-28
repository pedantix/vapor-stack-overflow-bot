import Vapor
struct StackOverflowUrlService: Service {
    let baseUrlString = "https://api.stackexchange.com/2.2/questions?order=desc&site=stackoverflow&sort=activity"

    func requestForQuestions(
        for tag: String,
        timeAgo: TimeInterval = 5 * 60 // Default to 5 Minutes
    ) -> URLRepresentable {
        let fromDate = Int(Date().addingTimeInterval(timeAgo *  -1).timeIntervalSince1970)
        return baseUrlString + "&tagged=\(tag)" + "&fromdate=\(fromDate)"
    }
}


extension StackOverflowUrlService: ServiceType {
    static func makeService(for worker: Container) throws -> StackOverflowUrlService {
        return .init()
    }
}
