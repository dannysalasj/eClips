import Foundation

// Defines a single error type for all network calls
enum NetworkError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case invalidResponse
}

class NetworkDataService {
    
    // Uses this shared instance in the app
    static let shared = NetworkDataService()
    
    // This is the URL that hosts the vlrggapi!
    // We'll use this for all our local server calls.
    private let vlrNewsAPIBaseURL = "http://127.0.0.1:5000/api"
    
    // A  decoder for the News API, which uses 'lowercase' keys
    private var newsDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        return decoder
    }
    
    // MARK: - News Scraper API Call
    
    /// Fetches Valorant news articles from your hosted vlrggapi
    public func fetchVALNews() async throws -> [VALNewsArticle] {
        // 1. Construct the URL
        // FIXED: Using the new /api/val_news endpoint
        guard let url = URL(string: "\(vlrNewsAPIBaseURL)/val_news") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Perform the request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Check for a valid 200 (OK) response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 4. Decode the data
        do {
            let responseWrapper = try newsDecoder.decode(VALNewsResponse.self, from: data)
            return responseWrapper.data.segments
        } catch {
            print("Decoding Error: \(error)") // Add this for debugging
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Fetches Overwatch news articles from your hosted scraper
    public func fetchOWNews() async throws -> [OWNewsArticle] {
        // 1. Construct the URL to the new endpoint
        guard let url = URL(string: "\(vlrNewsAPIBaseURL)/ow_news") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Perform the request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Check for a valid 200 (OK) response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 4. Decode the data (uses the new OWNewsResponse structure)
        do {
            // UPDATED: Decode using OWNewsResponse
            let responseWrapper = try newsDecoder.decode(OWNewsResponse.self, from: data)
            return responseWrapper.data.segments
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Fetches Rocket League news articles from your hosted scraper
    public func fetchRLNews() async throws -> [RLNewsArticle] {
        // 1. Construct the URL to the new endpoint
        guard let url = URL(string: "\(vlrNewsAPIBaseURL)/rl_news") else {
            throw NetworkError.invalidURL
        }
        
        // 2. Perform the request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // 3. Check for a valid 200 (OK) response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // 4. Decode the data
        do {
            // This now uses the GLOBAL RLNewsResponse from Models.swift
            let responseWrapper = try newsDecoder.decode(RLNewsResponse.self, from: data)
            
            // This now correctly returns the GLOBAL [RLNewsArticle]
            return responseWrapper.data.segments
        } catch {
            print("Decoding Error: \(error)")
            throw NetworkError.decodingError(error)
        }
    }
}
