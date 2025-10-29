//
//  ValorantView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

// MARK: - Data Models (Valorant Specific)
struct VALMatch: Identifiable, Decodable {
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

struct VALTeam: Identifiable, Decodable {
    let id: String
    let name: String
    let region: String
}

struct VALNewsItem: Identifiable, Decodable {
    let id: String
    let title: String
    let source: String
    let date: String
}

struct VALForumTopic: Identifiable, Decodable {
    let id: String
    let title: String
    let author: String
    let replies: Int
}

// MARK: - ViewModel (Valorant)
class ValorantViewModel: ObservableObject {
    @Published var completedMatches: [VALMatch] = []
    @Published var americasTeams: [VALTeam] = []
    @Published var newsItems: [VALNewsItem] = []
    @Published var forumTopics: [VALForumTopic] = []

    init() {
        fetchValorantData()
    }

    func fetchValorantData() {
        // --- MOCK DATA SIMULATING COMPLETED MATCHES (Valorant) ---
        let matchesJson = """
        [
            {"id": "val_m1", "tournament": "VCT Americas Grand Final", "team1Name": "LOUD", "team2Name": "Sentinels", "team1Score": 3, "team2Score": 2, "date": "2024-05-12"},
            {"id": "val_m2", "tournament": "VCT Americas League", "team1Name": "NRG", "team2Name": "Cloud9", "team1Score": 1, "team2Score": 2, "date": "2024-04-20"},
            {"id": "val_m3", "tournament": "Challengers NA", "team1Name": "M80", "team2Name": "Oxygen Esports", "team1Score": 2, "team2Score": 0, "date": "2024-03-01"}
        ]
        """
        
        // --- MOCK DATA SIMULATING 5 AMERICAS TEAMS (Valorant) ---
        let teamsJson = """
        [
            {"id": "val_t1", "name": "LOUD", "region": "Americas"},
            {"id": "val_t2", "name": "Sentinels", "region": "Americas"},
            {"id": "val_t3", "name": "Cloud9", "region": "Americas"},
            {"id": "val_t4", "name": "NRG", "region": "Americas"},
            {"id": "val_t5", "name": "Evil Geniuses", "region": "Americas"}
        ]
        """
        
        // --- MOCK DATA SIMULATING NEWS ---
        let newsJson = """
        [
            {"id": "val_n1", "title": "Patch 8.10: Massive changes to Viper and Clove on the horizon.", "source": "Riot Games", "date": "2025-10-28"},
            {"id": "val_n2", "title": "Sentinels announce new head coach for 2025 season.", "source": "VCT Wire", "date": "2025-10-25"},
            {"id": "val_n3", "title": "Ascent map temporarily removed from competitive rotation.", "source": "Liquipedia", "date": "2025-10-24"}
        ]
        """

        // --- MOCK DATA SIMULATING FORUMS ---
        let forumsJson = """
        [
            {"id": "val_f1", "title": "Who is the most underrated duelist in the Americas VCT?", "author": "ValorantFanatic", "replies": 345},
            {"id": "val_f2", "title": "Should Riot add a new map based in Latin America?", "author": "MapCreator1", "replies": 1201},
            {"id": "val_f3", "title": "My favorite clutch plays from the last VCT event!", "author": "HighlightReel", "replies": 88}
        ]
        """

        do {
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([VALMatch].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([VALTeam].self, from: teamsJson.data(using: .utf8)!)
            self.newsItems = try decoder.decode([VALNewsItem].self, from: newsJson.data(using: .utf8)!)
            self.forumTopics = try decoder.decode([VALForumTopic].self, from: forumsJson.data(using: .utf8)!)

        } catch {
            print("Failed to decode mock data: \(error)")
        }
    }
}


// MARK: - Main View
struct ValorantView: View {
    @StateObject var viewModel = ValorantViewModel()

    init() {
        // Set navigation bar appearance for this view
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.red
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Apply the appearance to all navigation bars in this view
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.red
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("valorant")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: ValorantMatchesView(viewModel: viewModel)) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantTeamsView(viewModel: viewModel)) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantNewsView(viewModel: viewModel)) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantForumsView(viewModel: viewModel)) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Valorant", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.red, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Updated Destination Views

struct ValorantMatchesView: View {
    @ObservedObject var viewModel: ValorantViewModel

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
                            .foregroundColor(.red)
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

struct ValorantTeamsView: View {
    @ObservedObject var viewModel: ValorantViewModel

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

struct ValorantNewsView: View {
    @ObservedObject var viewModel: ValorantViewModel
    
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
                            .foregroundColor(.red)
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

struct ValorantForumsView: View {
    @ObservedObject var viewModel: ValorantViewModel

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
                            .foregroundColor(.red)
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
