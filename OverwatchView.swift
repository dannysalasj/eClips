//
//  OverwatchView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

// MARK: - Data Models (Overwatch Specific)
struct OWMatch: Identifiable, Decodable {
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

struct OWTeam: Identifiable, Decodable {
    let id: String
    let name: String
    let region: String
}

struct OWNewsItem: Identifiable, Decodable {
    let id: String
    let title: String
    let source: String
    let date: String
}

struct OWForumTopic: Identifiable, Decodable {
    let id: String
    let title: String
    let author: String
    let replies: Int
}

// MARK: - ViewModel
class OverwatchViewModel: ObservableObject {
    @Published var completedMatches: [OWMatch] = []
    @Published var americasTeams: [OWTeam] = []
    @Published var newsItems: [OWNewsItem] = []
    @Published var forumTopics: [OWForumTopic] = []

    init() {
        fetchOverwatchData()
    }

    func fetchOverwatchData() {
        // --- MOCK DATA SIMULATING COMPLETED MATCHES ---
        let matchesJson = """
        [
            {
                "id": "ow_m1",
                "tournament": "OWL 2024 Grand Finals",
                "team1Name": "Atlanta Reign",
                "team2Name": "Boston Uprising",
                "team1Score": 4,
                "team2Score": 2,
                "date": "2024-10-28"
            },
            {
                "id": "ow_m2",
                "tournament": "Contenders NA Summer",
                "team1Name": "Toronto Defiant Academy",
                "team2Name": "Karmina Corp",
                "team1Score": 2,
                "team2Score": 3,
                "date": "2024-10-25"
            },
            {
                "id": "ow_m3",
                "tournament": "OWL Regular Season",
                "team1Name": "San Francisco Shock",
                "team2Name": "Dallas Fuel",
                "team1Score": 3,
                "team2Score": 0,
                "date": "2024-10-20"
            }
        ]
        """
        
        // --- MOCK DATA SIMULATING 5 AMERICAS TEAMS ---
        let teamsJson = """
        [
            {"id": "ow_t1", "name": "Atlanta Reign", "region": "Americas"},
            {"id": "ow_t2", "name": "Boston Uprising", "region": "Americas"},
            {"id": "ow_t3", "name": "Toronto Defiant", "region": "Americas"},
            {"id": "ow_t4", "name": "Vancouver Titans", "region": "Americas"},
            {"id": "ow_t5", "name": "Dallas Fuel", "region": "Americas"}
        ]
        """

        // --- MOCK DATA SIMULATING NEWS ---
        let newsJson = """
        [
            {"id": "ow_n1", "title": "New Tank Hero 'Nova' Revealed with Launch Trailer and Abilities", "source": "Blizzard Entertainment", "date": "2025-10-29"},
            {"id": "ow_n2", "title": "Boston Uprising announces full roster changes for the next Pro-Am tournament.", "source": "Overwatch Wire", "date": "2025-10-27"},
            {"id": "ow_n3", "title": "Flashpoint Map temporarily disabled due to critical pathing bug.", "source": "Competitive Overwatch", "date": "2025-10-26"}
        ]
        """

        // --- MOCK DATA SIMULATING FORUMS ---
        let forumsJson = """
        [
            {"id": "ow_f1", "title": "Who do you think is the best Zarya player right now? Discussion.", "author": "TankMain77", "replies": 560},
            {"id": "ow_f2", "title": "Request: New competitive mode rule set for one-tank.", "author": "RuleChanger", "replies": 1823},
            {"id": "ow_f3", "title": "My favorite legendary skins from the Halloween event!", "author": "CollectorOW", "replies": 95}
        ]
        """

        do {
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([OWMatch].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([OWTeam].self, from: teamsJson.data(using: .utf8)!)
            self.newsItems = try decoder.decode([OWNewsItem].self, from: newsJson.data(using: .utf8)!)
            self.forumTopics = try decoder.decode([OWForumTopic].self, from: forumsJson.data(using: .utf8)!)

        } catch {
            print("Failed to decode mock data: \(error)")
        }
    }
}


// MARK: - Main View
struct OverwatchView: View {
    @StateObject var viewModel = OverwatchViewModel()
    
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.orange
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("overwatch2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: OverwatchMatchesView(viewModel: viewModel)) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchTeamsView(viewModel: viewModel)) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchNewsView(viewModel: viewModel)) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchForumsView(viewModel: viewModel)) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Overwatch 2", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Updated Destination Views

struct OverwatchMatchesView: View {
    @ObservedObject var viewModel: OverwatchViewModel
    
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
                            .foregroundColor(.orange)
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

struct OverwatchTeamsView: View {
    @ObservedObject var viewModel: OverwatchViewModel
    
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

struct OverwatchNewsView: View {
    @ObservedObject var viewModel: OverwatchViewModel
    
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
                            .foregroundColor(.orange)
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

struct OverwatchForumsView: View {
    @ObservedObject var viewModel: OverwatchViewModel

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
                            .foregroundColor(.orange)
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

