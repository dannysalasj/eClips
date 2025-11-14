import SwiftUI
import Clerk

// MARK: - Data Models
// NOTE: VALNewsItem was removed, as it's now 'NewsArticle' in Models.swift
// The other models are left for now but will be replaced as you integrate
// your network calls for Matches and Teams.
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

// VALNewsItem struct was removed.

struct VALForumTopic: Identifiable, Codable { // Conforms to Codable for persistence
    let id: String
    let title: String
    let author: String
    let replies: Int
}

// MARK: - Persistence Manager
class VALForumPersistenceManager {
    static let key = "ValorantCustomForums"
    
    static func save(_ topics: [VALForumTopic]) {
        if let encoded = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    static func load() -> [VALForumTopic] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedTopics = try? JSONDecoder().decode([VALForumTopic].self, from: savedData) {
            return decodedTopics
        }
        return []
    }
}

// MARK: - ViewModel
class ValorantViewModel: ObservableObject {
    @Published var completedMatches: [VALMatch] = []
    @Published var americasTeams: [VALTeam] = []
    @Published var newsItems: [NewsArticle] = [] // <-- UPDATED to use NewsArticle
    @Published var forumTopics: [VALForumTopic] = []

    private var initialForumTopics: [VALForumTopic] = []
    @Published private var customForumTopics: [VALForumTopic] = VALForumPersistenceManager.load()

    // init() removed - data will be loaded via .task

    private func updateForumTopics() {
        self.forumTopics = customForumTopics + initialForumTopics
    }

    // --- UPDATED to be async and call the network service ---
    @MainActor
    func fetchValorantData() async {
        do {
            // --- MOCK DATA SIMULATING COMPLETED MATCHES ---
            let matchesJson = """
            [
                {"id": "val_m1", "tournament": "VCT Americas Grand Final", "team1Name": "LOUD", "team2Name": "Sentinels", "team1Score": 3, "team2Score": 2, "date": "2024-05-12"},
                {"id": "val_m2", "tournament": "VCT Americas League", "team1Name": "NRG", "team2Name": "Cloud9", "team1Score": 1, "team2Score": 2, "date": "2024-04-20"},
                {"id": "val_m3", "tournament": "Challengers NA", "team1Name": "M80", "team2Name": "Oxygen Esports", "team1Score": 2, "team2Score": 0, "date": "2024-03-01"}
            ]
            """
            
            // --- MOCK DATA SIMULATING 5 AMERICAS TEAMS ---
            let teamsJson = """
            [
                {"id": "val_t1", "name": "LOUD", "region": "Americas"},
                {"id": "val_t2", "name": "Sentinels", "region": "Americas"},
                {"id": "val_t3", "name": "Cloud9", "region": "Americas"},
                {"id": "val_t4", "name": "NRG", "region": "Americas"},
                {"id": "val_t5", "name": "Evil Geniuses", "region": "Americas"}
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

            // --- LIVE DATA CALL FOR NEWS ---
            // The mock newsJson string was removed.
            self.newsItems = try await NetworkDataService.shared.fetchNews()
            
            // --- Decode other mock data (for now) ---
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([VALMatch].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([VALTeam].self, from: teamsJson.data(using: .utf8)!)
            
            self.initialForumTopics = try decoder.decode([VALForumTopic].self, from: forumsJson.data(using: .utf8)!)
            updateForumTopics()

        } catch {
            print("Failed to decode or fetch data: \(error)")
        }
    }
    
    func addForumTopic(title: String, author: String) {
        let newTopic = VALForumTopic(
            id: UUID().uuidString,
            title: title,
            author: author,
            replies: 0
        )
        
        customForumTopics.insert(newTopic, at: 0)
        VALForumPersistenceManager.save(customForumTopics)
        
        updateForumTopics()
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
        
        // --- ADDED: Set the Tab Bar Appearance (Bottom Bar) ---
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.black
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        // --- MODIFIED: Replaced ZStack and NavigationLinks with TabView ---
        TabView {
            // 1. Matches Tab
            ValorantMatchesView(viewModel: viewModel)
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            ValorantTeamsView(viewModel: viewModel)
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            ValorantNewsView(viewModel: viewModel)
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab (Like the "Groups" icon in your screenshot)
            ValorantForumsView(viewModel: viewModel)
                .tabItem {
                    Label("Forums", systemImage: "person.2.fill") // Similar to the groups/community icon
                }
        }
        .accentColor(.red) // Sets the color for the selected tab icon
        .background(Color.black.edgesIgnoringSafeArea(.all)) // TabView Background
        .navigationBarTitle("Valorant", displayMode: .inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        // --- ADDED: This task modifier calls your network service once ---
        .task {
            await viewModel.fetchValorantData()
        }
    }
}


// MARK: - Forms Views

struct VALNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ValorantViewModel
    @Environment(\.clerk) private var clerk

    @State private var newTopicTitle: String = ""
    @State private var newTopicBody: String = "Write your discussion here..."

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Details").foregroundColor(.red)) {
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
            .navigationTitle("New Valorant Forum")
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
                    .foregroundColor(.red)
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


struct ValorantForumsView: View {
    @ObservedObject var viewModel: ValorantViewModel
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
                                .foregroundColor(.red)
                        } else {
                            Text("By \(topic.author)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
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
            VALNewForumTopicView(viewModel: viewModel)
        }
    }
}

// MARK: - Other Destination Views

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

// --- THIS ENTIRE VIEW HAS BEEN UPDATED ---
struct ValorantNewsView: View {
    @ObservedObject var viewModel: ValorantViewModel
    
    var body: some View {
        List {
            // Show a loading indicator while data is being fetched
            if viewModel.newsItems.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .listRowBackground(Color.black)
            } else {
                // Once data is loaded, display it
                ForEach(viewModel.newsItems) { item in
                    // Wrap in a Link to make it tappable
                    Link(destination: URL(string: item.link)!) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                Text(item.author) // Changed from .source
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                Spacer()
                                Text(item.date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listRowBackground(Color.black)
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .scrollContentBackground(.hidden)
        .navigationBarTitle("News", displayMode: .inline)
    }
}
