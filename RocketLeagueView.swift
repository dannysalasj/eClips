import SwiftUI
import Clerk

// MARK: - Data Models (Rocket League Specific)
struct RLMatchInfo: Identifiable, Decodable {
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

struct RLTeamInfo: Identifiable, Decodable {
    let id: String
    let name: String
    let region: String
}

// --- MOCK STRUCT 'RLNewsItem' REMOVED ---
// We now use 'RLNewsArticle' from Models.swift

struct RLForumTopic: Identifiable, Codable { // Conforms to Codable for persistence
    let id: String
    let title: String
    let author: String
    var replies: Int // CHANGED to VAR
}


// MARK: - Persistence Manager
class RLForumPersistenceManager {
    static let key = "RLForumCustomTopics"
    
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

// MARK: - Reply Data Model (NEW)
struct RLForumReply: Identifiable, Codable {
    let id: UUID
    let topicID: String // The ID of the parent RLForumTopic
    let author: String
    let text: String
    let date: Date
}

// MARK: - Reply Persistence Manager (NEW)
class RLReplyPersistenceManager {
    static let key = "RLForumReplies" // A single key to store ALL replies
    
    // Load all replies from UserDefaults
    static func load() -> [RLForumReply] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedReplies = try? JSONDecoder().decode([RLForumReply].self, from: savedData) {
            return decodedReplies
        }
        return []
    }
    
    // Save all replies to UserDefaults
    static func save(_ replies: [RLForumReply]) {
        if let encoded = try? JSONEncoder().encode(replies) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}


// MARK: - ViewModel (Rocket League)
class RLViewModel: ObservableObject {
    @Published var completedMatches: [RLMatchInfo] = []
    @Published var americasTeams: [RLTeamInfo] = []
    @Published var newsItems: [RLNewsArticle] = [] // <-- 1. CHANGED from RLNewsItem
    @Published var forumTopics: [RLForumTopic] = []
    @Published var isLoadingNews = true // <-- 2. ADDED loading state
    
    @Published var replies: [RLForumReply] = []

    private var initialForumTopics: [RLForumTopic] = []
    @Published private var customForumTopics: [RLForumTopic] = RLForumPersistenceManager.load()


    init() {
        self.replies = RLReplyPersistenceManager.load()
        // REMOVED fetchRLData() from init, we'll use .task in the View
    }
    
    private func updateForumTopics() {
        self.forumTopics = customForumTopics + initialForumTopics
    }
    
    func getReplies(for topicID: String) -> [RLForumReply] {
        return replies
            .filter { $0.topicID == topicID }
            .sorted { $0.date < $1.date }
    }

    // --- 3. REPLACED 'fetchRLData' with an async network call ---
    @MainActor
    func fetchRLData() async {
        
        self.isLoadingNews = true
        
        do {
            // --- MOCK DATA SIMULATING COMPLETED MATCHES (Rocket League) ---
            let matchesJson = """
            [
                {"id": "rl_m1", "tournament": "RLCS Major 1 Grand Final", "team1Name": "G2 Esports", "team2Name": "FURIA Esports", "team1Score": 4, "team2Score": 3, "date": "2024-03-24"},
                {"id": "rl_m2", "tournament": "RLCS North American Open 3", "team1Name": "Gen.G", "team2Name": "Spacestation Gaming", "team1Score": 3, "team2Score": 1, "date": "2024-02-18"},
                {"id": "rl_m3", "tournament": "RLCS South American Open 1", "team1Name": "Ninjas in Pyjamas", "team2Name": "The Club", "team1Score": 4, "team2Score": 1, "date": "2024-01-20"}
            ]
            """
            
            // --- MOCK DATA SIMULATING 5 AMERICAS TEAMS ---
            let teamsJson = """
            [
                {"id": "rl_t1", "name": "G2 Esports", "region": "Americas"},
                {"id": "rl_t2", "name": "FURIA Esports", "region": "Americas"},
                {"id": "rl_t3", "name": "Complexity Gaming", "region": "Americas"},
                {"id": "rl_t4", "name": "Shopify Rebellion", "region": "Americas"},
                {"id": "rl_t5", "name": "Spacestation Gaming", "region": "Americas"}
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

            // --- REAL NETWORK CALL FOR NEWS ---
            self.newsItems = try await NetworkDataService.shared.fetchRLNews()

            // --- DECODE MOCK DATA (MATCHES, TEAMS, FORUMS) ---
            let decoder = JSONDecoder()
            self.completedMatches = try decoder.decode([RLMatchInfo].self, from: matchesJson.data(using: .utf8)!)
            self.americasTeams = try decoder.decode([RLTeamInfo].self, from: teamsJson.data(using: .utf8)!)
            self.initialForumTopics = try decoder.decode([RLForumTopic].self, from: forumsJson.data(using: .utf8)!)
            updateForumTopics()

        } catch {
            print("Failed to decode or fetch data: \(error)")
        }
        
        self.isLoadingNews = false // <-- 4. ADDED
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
    
    func addReply(to topicID: String, text: String, author: String) {
        let newReply = RLForumReply(
            id: UUID(),
            topicID: topicID,
            author: author,
            text: text,
            date: Date()
        )
        replies.append(newReply)
        RLReplyPersistenceManager.save(replies)
        
        if let index = customForumTopics.firstIndex(where: { $0.id == topicID }) {
            customForumTopics[index].replies += 1
            RLForumPersistenceManager.save(customForumTopics)
        }
        else if let index = initialForumTopics.firstIndex(where: { $0.id == topicID }) {
            initialForumTopics[index].replies += 1
        }
        
        updateForumTopics()
        objectWillChange.send()
    }
}

// MARK: - Main View
struct RocketLeagueView: View {
    @StateObject var viewModel = RLViewModel()
    
    var body: some View {
        TabView {
            // 1. Matches Tab
            NavigationView {
                RLMatchesView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            NavigationView {
                RLTeamsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            NavigationView {
                RLNewsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab
            NavigationView {
                RLForumsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Forums", systemImage: "person.2.fill")
                }
        }
        .accentColor(.blue)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Rocket League", displayMode: .inline)
        .toolbarBackground(.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.blue
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        // --- 5. ADDED .task to call the async function ---
        .task {
            await viewModel.fetchRLData()
        }
    }
}

// MARK: - Forms Views

struct RLNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RLViewModel
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
                    .foregroundColor(.white)
                    .disabled(newTopicTitle.isEmpty)
                }
            }
        }
        .accentColor(.white)
    }

    private func postNewTopic() {
        let author = clerk.user?.username ?? "eClips User"
        viewModel.addForumTopic(title: newTopicTitle, author: author)
        dismiss()
    }
}

struct RLForumsView: View {
    @ObservedObject var viewModel: RLViewModel
    @State private var showingNewTopicSheet = false

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                NavigationLink(destination: RLForumDetailView(viewModel: viewModel, topic: topic)) {
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

struct RLForumDetailView: View {
    @ObservedObject var viewModel: RLViewModel
    @State var topic: RLForumTopic
    @Environment(\.clerk) private var clerk
    
    @State private var newReplyText: String = ""

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Author: \(topic.author)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(topic.replies) Replies")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)

                List(viewModel.getReplies(for: topic.id)) { reply in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reply.text)
                            .foregroundColor(.white)
                        HStack {
                            Text("by \(reply.author)")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Spacer()
                            Text(reply.date, style: .date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 5)
                    .listRowBackground(Color.black)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.black)

                HStack(spacing: 10) {
                    TextField("Write a reply...", text: $newReplyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(8)
                    
                    Button(action: postReply) {
                        Image(systemName: "paperplane.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(newReplyText.isEmpty)
                }
                .padding()
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            }
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func postReply() {
        let author = clerk.user?.username ?? "eClips User"
        viewModel.addReply(to: topic.id, text: newReplyText, author: author)
        topic.replies += 1
        newReplyText = ""
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Other Destination Views
struct RLMatchesView: View {
    @ObservedObject var viewModel: RLViewModel

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

struct RLTeamsView: View {
    @ObservedObject var viewModel: RLViewModel

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

// --- 6. UPDATED RLNewsView ---
struct RLNewsView: View {
    @ObservedObject var viewModel: RLViewModel

    var body: some View {
        List {
            // Show a loading indicator
            if viewModel.isLoadingNews {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .listRowBackground(Color.black)
            }
            // Show "No news" message
            else if viewModel.newsItems.isEmpty {
                Text("No news found.")
                    .foregroundColor(.gray)
                    .listRowBackground(Color.black)
            }
            // Show the news
            else {
                ForEach(viewModel.newsItems) { item in
                    Link(destination: URL(string: item.link) ?? URL(string: "https://www.google.com")!) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                Text(item.author) // <-- Changed from .source
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
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
