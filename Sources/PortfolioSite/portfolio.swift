import Foundation

// MARK: - Portfolio data model

struct Portfolio: Decodable {
    let role: String
    let introduction: String
    let languages: [PortfolioLanguage]
    let jobs: [Experience]
    let education: [Experience]
    let projects: [Project]
    let metadata: PortfolioMetadata
}

struct PortfolioLanguage: Decodable {
    let language: String
    let level: String
}

struct Experience: Decodable {
    let title: String
    let role: String
    let place: String
    let interval: String
    let responsibilities: [String]
    let technologies: [String]
    let diploma: String?
    let alt: String?
}

struct Project: Decodable {
    let name: String
    let description: String
    let link: String
}

struct PortfolioMetadata: Decodable {
    let language: String
    let webTitle: String
    let title: String
    let description: String
}

// MARK: - Loading

func loadPortfolio(for locale: Locale) throws -> Portfolio {
    let name = locale == .es ? "Spanish" : "English"
    guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
        fatalError("Missing \(name).json in Resources")
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(Portfolio.self, from: data)
}
