//
//  Untitled.swift
//  eClips
//
//  Created by Daniel Salas on 11/5/25.
//

import Foundation

// Define a single error type for all network calls
enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
}

class NetworkDataService {
    
    // Use this shared instance in your app
    static let shared = NetworkDataService()
    
    // --- Configuration ---
    // !! IMPORTANT: See setup instructions below !!
    private let pandascoreAPIKey = "C5h3lmAMZ6MUCf2CarjzRzoMTFKGS_Zq2Ko3ajv6KWfTaUOYMGY"
    private let pandascoreBaseURL = "https://api.pandascore.co"
    
    // !! IMPORTANT: This must be the URL where you host the vlrggapi !!
    private let vlrNewsAPIBaseURL = "http://127.0.0.1:5000/api"
    
    
    // --- Decoders ---
    
    // A decoder for Pandascore, which uses 'snake_case' keys
    private var pandascoreDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    // A standard decoder for the News API, which uses 'lowercase' keys
    private var newsDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }

    // MARK: - Pandascore API Calls
    
    /// A generic, reusable function to make calls to the Pandascore API
    private func makePandascoreRequest<T: Decodable>(endpoint: String) async throws -> T {
        // 1. Construct the URL
        guard let url = URL(string: "\(pandascoreBaseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Create the request and add the Auth header
        var request = URLRequest(url: url)
        request.setValue("Bearer \(pandascoreAPIKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // 3. Perform the request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 4. Check for a valid 200 (OK) response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 5. Decode the data
        do {
            let result = try pandascoreDecoder.decode(T.self, from: data)
            return result
        } catch {
            print("Decoding Error: \(error)") // Add this for debugging
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Fetches a list of upcoming Valorant matches
    public func fetchMatches() async throws -> [Match] {
        // Example: Get upcoming Valorant matches, sorted by date, 20 per page.
        // You can change "valorant" or the endpoint as needed.
        let endpoint = "/valorant/matches/upcoming?sort=begin_at&per_page=20"
        return try await makePandascoreRequest(endpoint: endpoint)
    }
    
    /// Fetches a list of Valorant teams
    public func fetchTeams() async throws -> [Team] {
        // Example: Get Valorant teams, 50 per page.
        let endpoint = "/valorant/teams?per_page=50"
        return try await makePandascoreRequest(endpoint: endpoint)
    }
    
    // MARK: - News Scraper API Call
    
    /// Fetches news articles from your hosted vlrggapi
    public func fetchNews() async throws -> [NewsArticle] {
        // 1. Construct the URL
        guard let url = URL(string: "\(vlrNewsAPIBaseURL)/news") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Perform the request (no auth needed for this one)
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Check for a valid 200 (OK) response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 4. Decode the data
        do {
            let articles = try newsDecoder.decode([NewsArticle].self, from: data)
            return articles
        } catch {
            print("Decoding Error: \(error)") // Add this for debugging
            throw NetworkError.decodingError(error)
        }
    }
}
