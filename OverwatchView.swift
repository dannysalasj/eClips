import SwiftUI
import Clerk

// MARK: - Data Models (Overwatch Specific)
// NOTE: OWNewsItem was removed. We now use the 'NewsArticle' model from Models.swift
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

// OWNewsItem struct removed.

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
    @Published var newsItems: [NewsArticle] = [] // Uses global NewsArticle
    @Published var forumTopics: [OWForumTopic] = []

    // --- 1. CHANGED: Added new loading state variable ---
    @Published var isLoadingNews = true

    private var initialForumTopics: [OWForumTopic] = []
    @Published private var customForumTopics: [OWForumTopic] = OWForumPersistenceManager.load()
    
    private func updateForumTopics() {
        // Combine custom (newest) and mock (initial) data
        self.forumTopics = customForumTopics + initialForumTopics
    }

    // --- 2. CHANGED: Updated fetch function ---
    @MainActor
    func fetchOverwatchData() async {
        
        // Start loading
        self.isLoadingNews = true
        
        do {
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

            // --- MOCK DATA SIMULATING FORUMS ---
            let forumsJson = """
            [
                {"id": "ow_f1", "title": "Who do you think is the best Zarya player right now? Discussion.", "author": "TankMain77", "replies": 560},
                {"id": "ow_f2", "title": "Request: New competitive mode rule set for one-tank.", "author": "RuleChanger", "replies": 1823},
                {"id": "ow_f3", "title": "My favorite legendary skins from the Halloween event!", "author": "CollectorOW", "replies": 95}
            ]
            """

            // --- LIVE DATA CALL FOR NEWS ---
            self.newsItems = try await NetworkDataService.shared.fetchOverwatchNews()

            // --- Decode other mock data (for now) ---
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([OWMatch].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([OWTeam].self, from: teamsJson.data(using: .utf8)!)
            
            self.initialForumTopics = try decoder.decode([OWForumTopic].self, from: forumsJson.data(using: .utf8)!)
            updateForumTopics() // Initial load and combination

        } catch {
            print("Failed to decode or fetch data: \(error)")
        }
        
        // --- ADDED: Tell the UI we are done loading ---
        self.isLoadingNews = false
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
    
    // NOTE: If you are using an iOS 16+ exclusive approach for UIBarAppearance,
    // you might remove this init block and use the new SwiftUI modifiers instead.
    init() {
        // Set navigation bar appearance for this view
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.orange // Overwatch Color
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
            OverwatchMatchesView(viewModel: viewModel)
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            OverwatchTeamsView(viewModel: viewModel)
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            OverwatchNewsView(viewModel: viewModel)
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab
            OverwatchForumsView(viewModel: viewModel)
                .tabItem {
                    Label("Forums", systemImage: "person.2.fill") // Community/Groups icon
                }
        }
        .accentColor(.orange) // Sets the color for the selected tab icon
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Overwatch 2", displayMode: .inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            // This now runs when the view appears
            await viewModel.fetchOverwatchData()
        }
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

// --- 3. CHANGED: This view now checks the 'isLoadingNews' state ---
struct OverwatchNewsView: View {
    @ObservedObject var viewModel: OverwatchViewModel
    
    var body: some View {
        List {
            // Show a loading indicator ONLY while loading
            if viewModel.isLoadingNews {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .listRowBackground(Color.black)
            }
            // If we are DONE loading and the list is still empty...
            else if viewModel.newsItems.isEmpty {
                // ...show a "No News" message
                Text("No news found.")
                    .foregroundColor(.gray)
                    .listRowBackground(Color.black)
            }
            // If we are done loading and have news, show it
            else {
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
                                    .foregroundColor(.orange)
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
