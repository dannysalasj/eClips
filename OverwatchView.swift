//
//  OverwatchView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI
import Clerk

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

struct OWForumTopic: Identifiable, Codable { // Conforms to Codable for persistence
    let id: String
    let title: String
    let author: String
    let replies: Int
}

// MARK: - Persistence Manager
class OWForumPersistenceManager {
    static let key = "OverwatchCustomForums"
    
    static func save(_ topics: [OWForumTopic]) {
        if let encoded = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func load() -> [OWForumTopic] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedTopics = try? JSONDecoder().decode([OWForumTopic].self, from: savedData) {
            return decodedTopics
        }
        return []
    }
}

// MARK: - ViewModel
class OverwatchViewModel: ObservableObject {
    @Published var completedMatches: [OWMatch] = []
    @Published var americasTeams: [OWTeam] = []
    @Published var newsItems: [OWNewsItem] = []
    @Published var forumTopics: [OWForumTopic] = []

    private var initialForumTopics: [OWForumTopic] = []
    @Published private var customForumTopics: [OWForumTopic] = OWForumPersistenceManager.load()

    init() {
        fetchOverwatchData()
    }
    
    private func updateForumTopics() {
        // Combine custom (newest) and mock (initial) data
        self.forumTopics = customForumTopics + initialForumTopics
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
            
            self.initialForumTopics = try decoder.decode([OWForumTopic].self, from: forumsJson.data(using: .utf8)!)
            updateForumTopics() // Initial load and combination

        } catch {
            print("Failed to decode mock data: \(error)")
        }
    }
    
    func addForumTopic(title: String, author: String) {
        let newTopic = OWForumTopic(
            id: UUID().uuidString,
            title: title,
            author: author,
            replies: 0
        )
        
        // Add to the custom list and persist
        customForumTopics.insert(newTopic, at: 0)
        OWForumPersistenceManager.save(customForumTopics)
        
        // Update the published array to refresh the view
        updateForumTopics()
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

// MARK: - Forms Views

struct OWNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: OverwatchViewModel
    @Environment(\.clerk) private var clerk // To get the author name

    @State private var newTopicTitle: String = ""
    @State private var newTopicBody: String = "Write your discussion here..."

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Details").foregroundColor(.orange)) {
                    TextField("Topic Title (Required)", text: $newTopicTitle)
                        .foregroundColor(.white)
                        .listRowBackground(Color.black)
                    
                    TextEditor(text: $newTopicBody)
                        .frame(height: 150)
                        .foregroundColor(.white)
                        .listRowBackground(Color.black)
                }
                .listRowSeparator(.hidden)
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .scrollContentBackground(.hidden)
            .navigationTitle("New Overwatch Forum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        postNewTopic()
                    }
                    .foregroundColor(.orange)
                    .disabled(newTopicTitle.isEmpty)
                }
            }
        }
        .accentColor(.white)
    }

    private func postNewTopic() {
        // Use the logged-in user's first name, or a generic name if unavailable
        let author = clerk.user?.firstName ?? "Anonymous"
        viewModel.addForumTopic(title: newTopicTitle, author: author)
        dismiss()
    }
}


struct OverwatchForumsView: View {
    @ObservedObject var viewModel: OverwatchViewModel
    @State private var showingNewTopicSheet = false

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        // Highlight user-created topics with 0 replies in this mock scenario
                        if topic.replies == 0 {
                            Text("By \(topic.author) (User Post)")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        } else {
                            Text("By \(topic.author)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingNewTopicSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showingNewTopicSheet) {
            // Pass the viewModel to the new topic view
            OWNewForumTopicView(viewModel: viewModel)
        }
    }
}


// MARK: - Other Destination Views
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

// **This is the missing view that caused the error.**
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
