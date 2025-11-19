import SwiftUI
import Clerk
import Foundation // Needed for VALMockData

// MARK: - Data Models (Valorant Specific)
// These structs are now defined in VALMockData.swift and Models.swift
typealias VALMatchInfo = MockMatch
typealias VALTeamInfo = VALMockData.VALTeamInfo
typealias VALForumTopic = VALMockData.VALForumTopic

// MARK: - Persistence Manager
class VALForumPersistenceManager {
    static let key = "VALForumCustomTopics"
    
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

// MARK: - Reply Data Model (NEW)
struct VALForumReply: Identifiable, Codable {
    let id: UUID
    let topicID: String // The ID of the parent VALForumTopic
    let author: String
    let text: String
    let date: Date
}

// MARK: - Reply Persistence Manager (NEW)
class VALReplyPersistenceManager {
    static let key = "VALForumReplies" // A single key to store ALL replies
    
    // Load all replies from UserDefaults
    static func load() -> [VALForumReply] {
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedReplies = try? JSONDecoder().decode([VALForumReply].self, from: savedData) {
            return decodedReplies
        }
        return []
    }
    
    // Save all replies to UserDefaults
    static func save(_ replies: [VALForumReply]) {
        if let encoded = try? JSONEncoder().encode(replies) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}


// MARK: - ViewModel
class VALViewModel: ObservableObject {
    @Published var completedMatches: [VALMatchInfo] = []
    @Published var americasTeams: [VALTeamInfo] = []
    @Published var newsItems: [VALNewsArticle] = []
    @Published var forumTopics: [VALForumTopic] = []
    
    @Published var replies: [VALForumReply] = [] // <-- ADDED

    private var initialForumTopics: [VALForumTopic] = []
    @Published private var customForumTopics: [VALForumTopic] = VALForumPersistenceManager.load()

    // ADDED INIT
    init() {
        self.replies = VALReplyPersistenceManager.load()
    }

    private func updateForumTopics() {
        self.forumTopics = customForumTopics + initialForumTopics
    }
    
    // ADDED HELPER
    func getReplies(for topicID: String) -> [VALForumReply] {
        return replies
            .filter { $0.topicID == topicID }
            .sorted { $0.date < $1.date } // Show oldest first
    }

    @MainActor
    func fetchVALData() async {
        do {
            
            // --- LIVE DATA CALL FOR NEWS ---
            self.newsItems = try await NetworkDataService.shared.fetchVALNews()
            
            // --- REMOVED HARDCODED JSON STRINGS, NOW DIRECTLY ASSIGNED FROM MOCK FILES ---
            self.completedMatches = VALMockData.matches
            self.americasTeams = VALMockData.teams
            self.initialForumTopics = VALMockData.forumTopics
            
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
    
    // REPLACED FUNCTION: Now accepts text and author
    func addReply(to topicID: String, text: String, author: String) {
        // 1. Create the new reply
        let newReply = VALForumReply(
            id: UUID(),
            topicID: topicID,
            author: author,
            text: text,
            date: Date()
        )
        
        // 2. Add to the main replies array
        replies.append(newReply)
        
        // 3. Save all replies to persistence
        VALReplyPersistenceManager.save(replies)
        
        // 4. Increment the topic's reply *counter*
        if let index = customForumTopics.firstIndex(where: { $0.id == topicID }) {
            customForumTopics[index].replies += 1
            VALForumPersistenceManager.save(customForumTopics)
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
struct ValorantView: View {
    @StateObject var viewModel = VALViewModel()
    
    var body: some View {
        // --- MODIFIED: Uses TabView for main navigation ---
        TabView {
            // 1. Matches Tab
            NavigationView {
                VALMatchesView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Matches", systemImage: "sportscourt.fill")
                }

            // 2. Teams Tab
            NavigationView {
                VALTeamsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            // 3. News Tab
            NavigationView {
                VALNewsView(viewModel: viewModel)
            }
                .tabItem {
                    Label("News", systemImage: "newspaper.fill")
                }

            // 4. Forums Tab (Like the "Groups" icon in your screenshot)
            NavigationView {
                VALForumsView(viewModel: viewModel)
            }
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
            await viewModel.fetchVALData()
        }
        // --- FIXED: This modifier sets the appearance ONLY when this view appears ---
        .onAppear {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.red // Valorant's color
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // White text
            
            // Apply the appearance to all navigation bars in this view
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}


// MARK: - Forms Views

struct VALNewForumTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: VALViewModel
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


struct VALForumsView: View {
    @ObservedObject var viewModel: VALViewModel
    @State private var showingNewTopicSheet = false

    var body: some View {
        List {
            ForEach(viewModel.forumTopics) { topic in
                // WRAPPED IN NAVIGATIONLINK to enable viewing detail and replying
                NavigationLink(destination: VALForumDetailView(viewModel: viewModel, topic: topic)) {
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
            VALNewForumTopicView(viewModel: viewModel)
        }
    }
}

// REPLACED STRUCT: Forum Detail View
struct VALForumDetailView: View {
    @ObservedObject var viewModel: VALViewModel
    @State var topic: VALForumTopic // Keep this as @State
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
                            .foregroundColor(.red)
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
                                .foregroundColor(.red)
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
                            .background(Color.red)
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

// MARK: - Other Destination Views (Valorant Specific)

struct VALMatchesView: View {
    @ObservedObject var viewModel: VALViewModel

    var body: some View {
        List {
            ForEach(viewModel.completedMatches) { match in
                // MODIFIED: Wrapped content in Link to redirect to match results
                Link(destination: URL(string: "https://www.vlr.gg/matches/results")!) {
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

struct VALTeamsView: View {
    @ObservedObject var viewModel: VALViewModel

    var body: some View {
        List {
            ForEach(viewModel.americasTeams) { team in
                // MODIFIED: Wrapped content in Link to redirect to rankings
                Link(destination: URL(string: "https://www.vlr.gg/rankings")!) {
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

// --- THIS ENTIRE VIEW HAS BEEN UPDATED ---
struct VALNewsView: View {
    @ObservedObject var viewModel: VALViewModel
    
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
