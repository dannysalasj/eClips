import SwiftUI
import Clerk
import Foundation // Needed for OWMockData

// MARK: - Data Models (Overwatch Specific)
// These structs are now defined in OWMockData.swift and Models.swift
typealias OWMatchInfo = MockMatch
typealias OWTeamInfo = OWMockData.OWTeamInfo
typealias OWForumTopic = OWMockData.OWForumTopic

// NOTE: OWNewsItem mock struct REMOVED. Now uses OWNewsArticle from Models.swift.

// MARK: - Persistence Manager
class OWForumPersistenceManager {
    static let key = "OWForumCustomTopics"
    
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

// MARK: - Reply Data Model (NEW)
struct OWForumReply: Identifiable, Codable {
    let id: UUID
    let topicID: String // The ID of the parent OWForumTopic
    let author: String
    let text: String
    let date: Date
}

// MARK: - Reply Persistence Manager (NEW)
class OWReplyPersistenceManager {
    static let key = "OWForumReplies" // A single key to store ALL replies
    
    // Load all replies from UserDefaults
    static func load() -> [OWForumReply] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedReplies = try? JSONDecoder().decode([OWForumReply].self, from: savedData) {
            return decodedReplies
        }
        return []
    }
    
    // Save all replies to UserDefaults
    static func save(_ replies: [OWForumReply]) {
        if let encoded = try? JSONEncoder().encode(replies) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}


// MARK: - ViewModel
class OWViewModel: ObservableObject {
    @Published var completedMatches: [OWMatchInfo] = []
    @Published var americasTeams: [OWTeamInfo] = []
    @Published var newsItems: [OWNewsArticle] = []
    @Published var forumTopics: [OWForumTopic] = []
    
    @Published var replies: [OWForumReply] = [] // <-- ADDED
    
    @Published var isLoadingNews = true

    private var initialForumTopics: [OWForumTopic] = []
    @Published private var customForumTopics: [OWForumTopic] = OWForumPersistenceManager.load()
    
    // ADDED INIT
    init() {
        self.replies = OWReplyPersistenceManager.load()
    }
    
    private func updateForumTopics() {
        // Combine custom (newest) and mock (initial) data
        self.forumTopics = customForumTopics + initialForumTopics
    }
    
    // ADDED HELPER
    func getReplies(for topicID: String) -> [OWForumReply] {
        return replies
            .filter { $0.topicID == topicID }
            .sorted { $0.date < $1.date } // Show oldest first
    }

    @MainActor
    func fetchOWData() async {
        
        // Start loading
        self.isLoadingNews = true
        
        do {
            
            // --- LIVE DATA CALL FOR NEWS ---
            self.newsItems = try await NetworkDataService.shared.fetchOWNews()

            // --- REMOVED HARDCODED JSON STRINGS, NOW DIRECTLY ASSIGNED FROM MOCK FILES ---
            self.completedMatches = OWMockData.matches
            self.americasTeams = OWMockData.teams
            self.initialForumTopics = OWMockData.forumTopics
            
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
    
    // REPLACED FUNCTION: Now accepts text and author
    func addReply(to topicID: String, text: String, author: String) {
        // 1. Create the new reply
        let newReply = OWForumReply(
            id: UUID(),
            topicID: topicID,
            author: author,
            text: text,
            date: Date()
        )
        
        // 2. Add to the main replies array
        replies.append(newReply)
        
        // 3. Save all replies to persistence
        OWReplyPersistenceManager.save(replies)
        
        // 4. Increment the topic's reply *counter*
        if let index = customForumTopics.firstIndex(where: { $0.id == topicID }) {
            customForumTopics[index].replies += 1
            OWForumPersistenceManager.save(customForumTopics)
        }
        else if let index = initialForumTopics.firstIndex(where: { $0.id == topicID }) {
            initialForumTopics[index].replies += 1
        }
        
        // 5. Update the published combined list
        updateForumTopics()
        
        // 6. Manually trigger an objectWillChange to force UI refresh
        objectWillChange.send()
    }
}


// MARK: - Main View
struct OverwatchView: View {
    @StateObject var viewModel = OWViewModel()
    
    // REMOVED: init() method
    
    var body: some View {
        // --- REVERTED: Uses TabView for main navigation ---
        TabView {
            // 1. Matches Tab
            NavigationView {
                OWMatchesView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            NavigationView {
                OWTeamsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            NavigationView {
                OWNewsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab
            NavigationView {
                OWForumsView(viewModel: viewModel)
            }
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
            await viewModel.fetchOWData()
        }
        // --- FIXED: This modifier sets the appearance ONLY when this view appears ---
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.orange // Overwatch's color
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // White text
            
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
// MARK: - Forms Views

struct OWNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: OWViewModel
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
                    .foregroundColor(.white) // FIXED: Post button color set to WHITE
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


struct OWForumsView: View {
    @ObservedObject var viewModel: OWViewModel
    @State private var showingNewTopicSheet = false

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                // WRAPPED IN NAVIGATIONLINK to enable viewing detail and replying
                NavigationLink(destination: OWForumDetailView(viewModel: viewModel, topic: topic)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(topic.title)
                            .font(.headline)
                            .foregroundColor(.white)
                        HStack {
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
                        .foregroundColor(.white) // FIXED: Toolbar button set to WHITE
                }
            }
        }
        .sheet(isPresented: $showingNewTopicSheet) {
            // Pass the viewModel to the new topic view
            OWNewForumTopicView(viewModel: viewModel)
        }
    }
}

// REPLACED STRUCT: Forum Detail View
struct OWForumDetailView: View {
    @ObservedObject var viewModel: OWViewModel
    @State var topic: OWForumTopic // Keep this as @State
    @Environment(\.clerk) private var clerk // To get the user's name
    
    @State private var newReplyText: String = "" // To hold new reply text

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 0) {
                // --- 1. Topic Card ---
                VStack(alignment: .leading, spacing: 5) {
                    Text(topic.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("Author: \(topic.author)")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        Spacer()
                        Text("\(topic.replies) Replies") // This will update automatically
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top)

                // --- 2. List of Replies ---
                List(viewModel.getReplies(for: topic.id)) { reply in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reply.text)
                            .foregroundColor(.white)
                        HStack {
                            Text("by \(reply.author)")
                                .font(.caption)
                                .foregroundColor(.orange)
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

                // --- 3. New Reply Input Area ---
                HStack(spacing: 10) {
                    TextField("Write a reply...", text: $newReplyText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(8)
                    
                    Button(action: postReply) {
                        Image(systemName: "paperplane.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.orange)
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
    
    // --- 4. Action for the Post Button ---
    private func postReply() {
        let author = clerk.user?.username ?? "eClips User"
        
        // Call the viewmodel function
        viewModel.addReply(to: topic.id, text: newReplyText, author: author)
        
        // Manually update the local state to see immediate changes
        topic.replies += 1
        
        // Clear the text field
        newReplyText = ""
        
        // Dismiss keyboard (optional, but good UX)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Other Destination Views
struct OWMatchesView: View {
    @ObservedObject var viewModel: OWViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.completedMatches) { match in
                // MODIFIED: Wrapped content in Link to redirect to OW match results
                Link(destination: URL(string: "https://owtv.gg/matches")!) {
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

struct OWTeamsView: View {
    @ObservedObject var viewModel: OWViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.americasTeams) { team in
                // MODIFIED: Wrapped content in Link to redirect to OW rankings
                Link(destination: URL(string: "https://esports.overwatch.com/en-us/rankings")!) {
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

struct OWNewsView: View {
    @ObservedObject var viewModel: OWViewModel
    
    var body: some View {
        List {
            // Show a loading indicator ONLY while loading
            if viewModel.isLoadingNews {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .listRowBackground(Color.black)
            }
            // If we are DONE loading and have news, show it
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
                    Link(destination: URL(string: item.link) ?? URL(string: "https://www.over.gg/news")!) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            HStack {
                                Text(item.author) // UPDATED to use .author (from OWNewsArticle)
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
