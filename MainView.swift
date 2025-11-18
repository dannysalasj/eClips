import SwiftUI
import Clerk

// MARK: - Main View Content
struct GameCard: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Used for the large card background/icon
    let primaryColor: Color // Used for accents like the NEW tag or icon background
    let details: [String] // List of event/link details for the card
    let destination: AnyView // The view to navigate to
}

@main
struct eClipsApp: App {
    @State private var clerk = Clerk.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(clerk)
                .task {
                    clerk.configure(publishableKey: "pk_test_Y29tcG9zZWQtcXVldHphbC0yOS5jbGVyay5hY2NvdW50cy5kZXYk")
                    try? await clerk.load()
                }
        }
    }
}

struct ContentView: View {
    @Environment(\.clerk) private var clerk
    
    var body: some View {
        Group {
            if let _ = clerk.user {
                MainView()
            } else {
                AuthView() // Ensures the app goes to auth if the user isn't present
            }
        }
    }
}

// --- NEW VIEWMODEL ---
@MainActor
class MainViewModel: ObservableObject {
    @Published var combinedNews: [UnifiedNewsArticle] = []
    @Published var isLoading = true
    
    func fetchAllNews() async {
        self.isLoading = true
        
        do {
            // Fetch all news feeds in parallel
            async let valNews = NetworkDataService.shared.fetchVALNews()
            async let owNews = NetworkDataService.shared.fetchOWNews()
            async let rlNews = NetworkDataService.shared.fetchRLNews()
            
            // Wait for all of them to complete
            let (val, ow, rl) = try await (valNews, owNews, rlNews)
            
            // --- Interleave the news as requested ---
            var interleavedNews: [UnifiedNewsArticle] = []
            
            // 1. Add the most recent of each
            if let val1 = val.first {
                interleavedNews.append(UnifiedNewsArticle(from: val1))
            }
            if let ow1 = ow.first {
                interleavedNews.append(UnifiedNewsArticle(from: ow1))
            }
            if let rl1 = rl.first {
                interleavedNews.append(UnifiedNewsArticle(from: rl1))
            }
            
            // 2. Add the second most recent of each
            if val.count > 1 {
                interleavedNews.append(UnifiedNewsArticle(from: val[1]))
            }
            if ow.count > 1 {
                interleavedNews.append(UnifiedNewsArticle(from: ow[1]))
            }
            if rl.count > 1 {
                interleavedNews.append(UnifiedNewsArticle(from: rl[1]))
            }
            
            self.combinedNews = interleavedNews
            
        } catch {
            print("Failed to fetch all news: \(error)")
            // You could set an error state here
        }
        
        self.isLoading = false
    }
}


struct MainView: View {
    @Environment(\.clerk) private var clerk
    
    // --- VIEWMODEL AND STATE ---
    @StateObject private var viewModel = MainViewModel()
    @State private var currentNewsIndex: Int = 0 // Tracks the slider position
    
    // --- CONSTANTS ---
    private let lightPurple = Color(red: 0.8, green: 0.6, blue: 1.0)
    
    private let gameCards: [GameCard] = [
        .init(name: "Overwatch 2",
              imageName: "overwatch2",
              primaryColor: .orange,
              details: ["MRIG 2025: Grand Finals", "MRC S4: EMEA PC", "MRC S4: AMER PC"],
              destination: AnyView(OverwatchView())),
        
        .init(name: "Valorant",
              imageName: "valorant",
              primaryColor: .red,
              details: ["Red Bull Home Ground 2025", "Game Changers Championship 2025", "CN EVO Series Epilogue"],
              destination: AnyView(ValorantView())),
                
        .init(name: "Rocket League",
              imageName: "rocketleague",
              primaryColor: .blue,
              details: ["PGL Wallachia Season 6", "1Win Not Int 3", "BLAST Slam IV"],
              destination: AnyView(RocketLeagueView())),
    ]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // --- HEADER (Unchanged) ---
                VStack(spacing: 0) {
                    HStack {
                        Text("eClips")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(lightPurple)
                            .padding(.leading, 15)
                        
                        Spacer()

                        Button("Log Out") {
                            Task {
                                do {
                                    try await clerk.signOut()
                                } catch {
                                    print("Error signing out: \(error)")
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.trailing, 15)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 2)
                    
                    HStack {
                        Text("Developed by gamers, for gamers.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.leading, 15)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
                .background(Color.black.opacity(0.8))
                .padding(.bottom, 15)
                
                // --- MODIFIED: News Slider with Arrows ---
                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 75)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 15)
                } else if !viewModel.combinedNews.isEmpty {
                    
                    HStack(spacing: 8) {
                        // --- Left Arrow Button ---
                        Button(action: cycleNewsBack) {
                            Image(systemName: "chevron.left")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        // --- News Slider ---
                        NewsSliderView(newsItem: viewModel.combinedNews[currentNewsIndex])
                            .frame(height: 75)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            // Use a swipe gesture
                            .gesture(
                                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                    .onEnded { value in
                                        if value.translation.width < -20 { // Swipe Left
                                            cycleNewsForward()
                                        }
                                        if value.translation.width > 20 { // Swipe Right
                                            cycleNewsBack()
                                        }
                                    }
                            )
                        
                        // --- Right Arrow Button ---
                        Button(action: cycleNewsForward) {
                            Image(systemName: "chevron.right")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 15)
                    
                } else {
                    // Show this if loading is done but no news was found
                    Text("No news available right now.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(height: 75)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 15)
                }
                
                // --- Game Cards (Unchanged) ---
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(gameCards) { card in
                            NavigationLink(destination: card.destination) {
                                GameCardView(card: card)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1))
            }
            .navigationBarHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .task {
                // --- Fetch all news when the view appears ---
                await viewModel.fetchAllNews()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // --- Functions for Arrow Buttons ---
    private func cycleNewsForward() {
        withAnimation(.easeInOut) {
            currentNewsIndex = (currentNewsIndex + 1) % viewModel.combinedNews.count
        }
    }
    
    private func cycleNewsBack() {
        withAnimation(.easeInOut) {
            currentNewsIndex = (currentNewsIndex - 1 + viewModel.combinedNews.count) % viewModel.combinedNews.count
        }
    }
}

// MARK: - NewsSliderView (MODIFIED)
struct NewsSliderView: View {
    // --- Accepts the new Unified Model ---
    let newsItem: UnifiedNewsArticle

    var body: some View {
        Link(destination: URL(string: newsItem.link) ?? URL(string: "https://www.google.com")!) {
            ZStack {
                // --- Background is now dynamic ---
                Image(newsItem.gameImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                
                // Overlay for readability
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                
                VStack(alignment: .leading) {
                    // --- Text is now dynamic ---
                    Text(newsItem.gameName.uppercased())
                        .font(.caption)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.bottom, 2)
                    
                    Text(newsItem.title)
                        .font(.callout)
                        .fontWeight(.bold)
                        // --- Color is now dynamic ---
                        .foregroundColor(newsItem.gameColor)
                        .lineLimit(1)
                    
                    HStack {
                        Text(newsItem.author)
                            .font(.caption2)
                            .foregroundColor(.white)
                        Spacer()
                        Text(newsItem.date)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(8)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - GameCardView (Unchanged)
struct GameCardView: View {
    let card: GameCard

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                // Card background image
                Image(card.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(8)
                
                if card.name == "Overwatch 2" {
                    Text("NEW")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(card.primaryColor)
                        .cornerRadius(5)
                        .offset(x: -8, y: 8)
                }
            }
            
            Text(card.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 5)

            // Event details
            VStack(alignment: .leading, spacing: 2) {
                ForEach(card.details.prefix(3), id: \.self) { detail in
                    Text(detail)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 5)
        }
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.15, green: 0.15, blue: 0.15))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
