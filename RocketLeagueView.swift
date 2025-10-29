//
//  RocketLeagueView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

// MARK: - Data Models (Rocket League Specific)
struct RLMatch: Identifiable, Decodable {
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

struct RLTeam: Identifiable, Decodable {
    let id: String
    let name: String
    let region: String
}

struct RLNewsItem: Identifiable, Decodable {
    let id: String
    let title: String
    let source: String
    let date: String
}

struct RLForumTopic: Identifiable, Decodable {
    let id: String
    let title: String
    let author: String
    let replies: Int
}


// MARK: - ViewModel (Rocket League)
class RocketLeagueViewModel: ObservableObject {
    @Published var completedMatches: [RLMatch] = []
    @Published var americasTeams: [RLTeam] = []
    @Published var newsItems: [RLNewsItem] = []
    @Published var forumTopics: [RLForumTopic] = []


    init() {
        fetchRocketLeagueData()
    }

    func fetchRocketLeagueData() {
        // --- MOCK DATA SIMULATING COMPLETED MATCHES (Rocket League) ---
        let matchesJson = """
        [
            {"id": "rl_m1", "tournament": "RLCS Major 1 Grand Final", "team1Name": "G2 Esports", "team2Name": "FURIA Esports", "team1Score": 4, "team2Score": 3, "date": "2024-03-24"},
            {"id": "rl_m2", "tournament": "RLCS North American Open 3", "team1Name": "Gen.G", "team2Name": "Spacestation Gaming", "team1Score": 3, "team2Score": 1, "date": "2024-02-18"},
            {"id": "rl_m3", "tournament": "RLCS South American Open 1", "team1Name": "Ninjas in Pyjamas", "team2Name": "The Club", "team1Score": 4, "team2Score": 1, "date": "2024-01-20"}
        ]
        """
        
        // --- MOCK DATA SIMULATING 5 AMERICAS TEAMS (Rocket League) ---
        let teamsJson = """
        [
            {"id": "rl_t1", "name": "G2 Esports", "region": "Americas"},
            {"id": "rl_t2", "name": "FURIA Esports", "region": "Americas"},
            {"id": "rl_t3", "name": "Complexity Gaming", "region": "Americas"},
            {"id": "rl_t4", "name": "Shopify Rebellion", "region": "Americas"},
            {"id": "rl_t5", "name": "Spacestation Gaming", "region": "Americas"}
        ]
        """
        
        // --- MOCK DATA SIMULATING NEWS ---
        let newsJson = """
        [
            {"id": "rl_n1", "title": "New RLCS format announced for the 2025-2026 season: More LANs!", "source": "Psyonix", "date": "2025-10-29"},
            {"id": "rl_n2", "title": "Complexity signs all-Brazilian roster after successful Major run.", "source": "RL Esports Hub", "date": "2025-10-27"},
            {"id": "rl_n3", "title": "RL Insider: Top 10 new wheels released in the latest patch.", "source": "RL Insider", "date": "2025-10-26"}
        ]
        """

        // --- MOCK DATA SIMULATING FORUMS ---
        let forumsJson = """
        [
            {"id": "rl_f1", "title": "Is the new RLCS circuit too demanding on player health?", "author": "RLProDebater", "replies": 890},
            {"id": "rl_f2", "title": "Which decal looks the best on the Octane? Post your setups!", "author": "CustomCarFan", "replies": 3205},
            {"id": "rl_f3", "title": "Theory: Next season's world championship location is Europe.", "author": "MapPredictor", "replies": 156}
        ]
        """

        do {
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([RLMatch].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([RLTeam].self, from: teamsJson.data(using: .utf8)!)
            self.newsItems = try decoder.decode([RLNewsItem].self, from: newsJson.data(using: .utf8)!)
            self.forumTopics = try decoder.decode([RLForumTopic].self, from: forumsJson.data(using: .utf8)!)

        } catch {
            print("Failed to decode mock data: \(error)")
        }
    }
}

// MARK: - Main View
struct RocketLeagueView: View {
    @StateObject var viewModel = RocketLeagueViewModel()

    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("rocketleague")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: RocketLeagueMatchesView(viewModel: viewModel)) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueTeamsView(viewModel: viewModel)) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueNewsView(viewModel: viewModel)) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueForumsView(viewModel: viewModel)) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Rocket League", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Updated Destination Views

struct RocketLeagueMatchesView: View {
    @ObservedObject var viewModel: RocketLeagueViewModel

    var body: some View {
        List {
            ForEach(viewModel.completedMatches) { match in
                VStack(alignment: .leading, spacing: 8) {
                    Text(match.tournament)
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        Text("\(match.team1Name) vs \(match.team2Name)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("**\(match.matchResult)**")
                            .foregroundColor(.blue)
                    }
                    Text(match.date)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .listRowBackground(Color.black)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle("Matches", displayMode: .inline)
    }
}

struct RocketLeagueTeamsView: View {
    @ObservedObject var viewModel: RocketLeagueViewModel

    var body: some View {
        List {
            ForEach(viewModel.americasTeams) { team in
                HStack {
                    Text(team.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Text(team.region)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .listRowBackground(Color.black)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle("Teams", displayMode: .inline)
    }
}

struct RocketLeagueNewsView: View {
    @ObservedObject var viewModel: RocketLeagueViewModel

    var body: some View {
        List {
            ForEach(viewModel.newsItems) { item in
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        Text(item.source)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text(item.date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .listRowBackground(Color.black)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle("News", displayMode: .inline)
    }
}

struct RocketLeagueForumsView: View {
    @ObservedObject var viewModel: RocketLeagueViewModel

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        Text("By \(topic.author)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("\(topic.replies) replies")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                .listRowBackground(Color.black)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle("Forums", displayMode: .inline)
    }
}
