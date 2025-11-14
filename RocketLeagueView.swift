import SwiftUI
import Clerk

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

struct RLForumTopic: Identifiable, Codable { // Conforms to Codable for persistence
    let id: String
    let title: String
    let author: String
    let replies: Int
}


// MARK: - Persistence Manager
class RLForumPersistenceManager {
    static let key = "RocketLeagueCustomForums"
    
    static func save(_ topics: [RLForumTopic]) {
        if let encoded = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func load() -> [RLForumTopic] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedTopics = try? JSONDecoder().decode([RLForumTopic].self, from: savedData) {
            return decodedTopics
        }
        return []
    }
}

// MARK: - ViewModel (Rocket League)
class RocketLeagueViewModel: ObservableObject {
    @Published var completedMatches: [RLMatch] = []
    @Published var americasTeams: [RLTeam] = []
    @Published var newsItems: [RLNewsItem] = []
    @Published var forumTopics: [RLForumTopic] = []

    private var initialForumTopics: [RLForumTopic] = []
    @Published private var customForumTopics: [RLForumTopic] = RLForumPersistenceManager.load()


    init() {
        fetchRocketLeagueData()
    }
    
    private func updateForumTopics() {
        self.forumTopics = customForumTopics + initialForumTopics
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
            
            self.initialForumTopics = try decoder.decode([RLForumTopic].self, from: forumsJson.data(using: .utf8)!)
            updateForumTopics()

        } catch {
            print("Failed to decode mock data: \(error)")
        }
    }
    
    func addForumTopic(title: String, author: String) {
        let newTopic = RLForumTopic(
            id: UUID().uuidString,
            title: title,
            author: author,
            replies: 0
        )
        
        customForumTopics.insert(newTopic, at: 0)
        RLForumPersistenceManager.save(customForumTopics)
        
        updateForumTopics()
    }
}

// MARK: - Main View
struct RocketLeagueView: View {
    @StateObject var viewModel = RocketLeagueViewModel()

    init() {
        // Set navigation bar appearance for this view
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.blue // Rocket League Color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        // --- Tab Bar Appearance (Bottom Bar) ---
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some View {
        // --- MODIFIED: Uses TabView for main navigation ---
        TabView {
            // 1. Matches Tab
            RocketLeagueMatchesView(viewModel: viewModel)
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            RocketLeagueTeamsView(viewModel: viewModel)
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            RocketLeagueNewsView(viewModel: viewModel)
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab
            RocketLeagueForumsView(viewModel: viewModel)
                .tabItem {
                    Label("Forums", systemImage: "person.2.fill") // Community/Groups icon
                }
        }
        .accentColor(.blue) // Sets the color for the selected tab icon
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Rocket League", displayMode: .inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        // NOTE: RocketLeagueViewModel currently uses mock data and doesn't have a .task call
    }
}
// MARK: - Forms Views

struct RLNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RocketLeagueViewModel
    @Environment(\.clerk) private var clerk

    @State private var newTopicTitle: String = ""
    @State private var newTopicBody: String = "Write your discussion here..."

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Details").foregroundColor(.blue)) {
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
            .navigationTitle("New Rocket League Forum")
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
                    .foregroundColor(.blue)
                    .disabled(newTopicTitle.isEmpty)
                }
            }
        }
        .accentColor(.white)
    }

    private func postNewTopic() {
        let author = clerk.user?.firstName ?? "Anonymous"
        viewModel.addForumTopic(title: newTopicTitle, author: author)
        dismiss()
    }
}

struct RocketLeagueForumsView: View {
    @ObservedObject var viewModel: RocketLeagueViewModel
    @State private var showingNewTopicSheet = false

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    HStack {
                        if topic.replies == 0 {
                            Text("By \(topic.author) (User Post)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        } else {
                            Text("By \(topic.author)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
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
            RLNewForumTopicView(viewModel: viewModel)
        }
    }
}

// MARK: - Other Destination Views
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
