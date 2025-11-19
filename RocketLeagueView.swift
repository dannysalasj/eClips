import SwiftUI
import Clerk
import Foundation // Needed for RLMockData

// MARK: - Data Models (Rocket League Specific)
// These structs are now defined in RLMockData.swift and Models.swift
typealias RLMatchInfo = MockMatch
typealias RLTeamInfo = RLMockData.RLTeamInfo
typealias RLForumTopic = RLMockData.RLForumTopic

// --- MOCK STRUCT 'RLNewsItem' REMOVED ---
// We now use 'RLNewsArticle' from Models.swift

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
           // --- FIX APPLIED HERE: Corrected JSONDecoder syntax ---
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
    @Published var newsItems: [RLNewsArticle] = []
    @Published var forumTopics: [RLForumTopic] = []
    @Published var isLoadingNews = true
    
    @Published var replies: [RLForumReply] = []

    private var initialForumTopics: [RLForumTopic] = []
    @Published private var customForumTopics: [RLForumTopic] = RLForumPersistenceManager.load()


    init() {
        self.replies = RLReplyPersistenceManager.load()
    }
    
    private func updateForumTopics() {
        self.forumTopics = customForumTopics + initialForumTopics
    }
    
    func getReplies(for topicID: String) -> [RLForumReply] {
        return replies
            .filter { $0.topicID == topicID }
            .sorted { $0.date < $1.date }
    }

    @MainActor
    func fetchRLData() async {
        
        self.isLoadingNews = true
        
        do {
            // --- REAL NETWORK CALL FOR NEWS ---
            self.newsItems = try await NetworkDataService.shared.fetchRLNews()

            // --- REMOVED HARDCODED JSON STRINGS, NOW DIRECTLY ASSIGNED FROM MOCK FILES ---
            self.completedMatches = RLMockData.matches
            self.americasTeams = RLMockData.teams
            self.initialForumTopics = RLMockData.forumTopics
            
            updateForumTopics()

        } catch {
            print("Failed to decode or fetch data: \(error)")
        }
        
        self.isLoadingNews = false
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
                // MODIFIED: Wrapped content in Link to redirect to RL match results
                Link(destination: URL(string: "https://tips.gg/rl/matches/")!) {
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
                // MODIFIED: Wrapped content in Link to redirect to RL teams/rankings
                Link(destination: URL(string: "https://tips.gg/rl/teams/")!) {
                    HStack {
                        Text(team.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text(team.region)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
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
