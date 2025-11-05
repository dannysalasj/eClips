//
//  Models.swift
//  eClips
//
//  Created by Daniel Salas on 11/5/25.
//

import Foundation

// MARK: - News Model
// Based on the vlr.gg scraper you linked.
// It returns simple lowercase keys, so these properties match directly.
struct NewsArticle: Codable, Identifiable {
    // The API doesn't provide a unique ID, so we create one
    // for SwiftUI's `Identifiable` conformance.
    let id = UUID()
    let title: String
    let author: String
    let date: String
    let link: String
    
    // We add this to tell Swift the JSON keys match our properties.
    enum CodingKeys: String, CodingKey {
        case title, author, date, link
    }
}

// MARK: - Pandascore Models

// Represents a single team.
// We use `Identifiable` for use in SwiftUI Lists.
struct Team: Codable, Identifiable {
    let id: Int
    let name: String
    let imageUrl: String? // Image URLs can sometimes be null
    let acronym: String?
}

// Represents a single match.
struct Match: Codable, Identifiable {
    let id: Int
    let name: String
    let beginAt: String? // This is an ISO 8601 date string, e.g., "2025-11-10T18:00:00Z"
    let status: String // e.g., "running", "finished", "not_started"
    let opponents: [Opponent]
}

// This is a helper struct for the `opponents` array inside `Match`.
// Pandascore nests the team data inside an "opponent" object.
struct Opponent: Codable, Identifiable {
    // We can use the team's id as the Identifiable id.
    var id: Int { team.id }
    let team: Team
}
