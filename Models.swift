import Foundation
import SwiftUI

// MARK: - UNIVERSAL MOCK MODEL
// A simple, reusable struct for all mock matches (MOVED FROM VALMockData.swift)
struct MockMatch: Identifiable, Decodable {
    let id: String
    let tournament: String
    let team1Name: String
    let team2Name: String
    let team1Score: Int
    let team2Score: Int
    let date: String

    var matchResult: String {
        "\(team1Score) - \(team2Score)"
    }
}

// MARK: - Unified News Model
// This struct can hold news from any game
struct UnifiedNewsArticle: Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let link: String
    
    // Custom properties for the slider
    let gameName: String
    let gameImageName: String
    let gameColor: Color

    // Initializer for Valorant News
    init(from article: VALNewsArticle) {
        self.title = article.title
        self.author = article.author
        self.date = article.date
        self.link = article.link
        self.gameName = "Valorant"
        self.gameImageName = "valorant" // Matches your GameCard image
        self.gameColor = .red
    }
    
    // Initializer for Overwatch News
    init(from article: OWNewsArticle) {
        self.title = article.title
        self.author = article.author
        self.date = article.date
        self.link = article.link
        self.gameName = "Overwatch 2"
        self.gameImageName = "overwatch2" // Matches your GameCard image
        self.gameColor = .orange
    }
    
    // Initializer for Rocket League News
    init(from article: RLNewsArticle) {
        self.title = article.title
        self.author = article.author
        self.date = article.date
        self.link = article.link
        self.gameName = "Rocket League"
        self.gameImageName = "rocketleague" // Matches your GameCard image
        self.gameColor = .blue
    }
}
// MARK: - News Scraper Models (Valorant Specific)

// 1. This matches the top-level "data" key
struct VALNewsResponse: Codable {
    let data: VALNewsData
}

// 2. This matches the "segments" key, which holds the array
struct VALNewsData: Codable {
    let segments: [VALNewsArticle]
}

// News Model (VALORANT SPECIFIC)
// It returns simple lowercase keys, so these properties match directly.
struct VALNewsArticle: Codable, Identifiable {
    
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let link: String
    // Note: VALNewsArticle assumes "description" is present based on VALScraper.py.
    // We'll keep the Python side consistent.
    
    // Maps JSON key "url_path" to Swift property "link"
    enum CodingKeys: String, CodingKey {
        case title, author, date
        case link = "url_path"
    }
}


// MARK: - News Scraper Models (Overwatch Specific)
// NEW: Dedicated models for OW news using the same structure/keys as VAL scraper output

struct OWNewsResponse: Codable {
    let data: OWNewsData
}

struct OWNewsData: Codable {
    let segments: [OWNewsArticle]
}

struct OWNewsArticle: Codable, Identifiable {
    
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let link: String
    // RE-ADDED: Description field to hold the snippet.
    let description: String
    
    // Maps JSON key "url_path" to Swift property "link"
    enum CodingKeys: String, CodingKey {
        case title, author, date, description // Added 'description' here for completeness
        case link = "url_path"
    }
}

// Add these structs to Models.swift

// MARK: - News Scraper Models (Rocket League Specific)

struct RLNewsResponse: Codable {
    let data: RLNewsData
}

struct RLNewsData: Codable {
    let segments: [RLNewsArticle]
}

struct RLNewsArticle: Codable, Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let link: String
    let description: String
    
    // Maps JSON key "url_path" to Swift property "link"
    enum CodingKeys: String, CodingKey {
        case title, author, date, description
        case link = "url_path"
    }
}
