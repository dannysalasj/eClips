import SwiftUI
import Clerk

// --- MODIFIED: Data structure for the main menu items (iconName removed) ---
struct GameCard: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String // Used for the large card background/icon
    let primaryColor: Color // Used for accents like the NEW tag or icon background
    let details: [String] // List of event/link details for the card
    let destination: AnyView // The view to navigate to
}
// --- END MODIFIED ---


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

// NEW Root View to Handle Authentication Flow
struct ContentView: View {
    @Environment(\.clerk) private var clerk
    
    var body: some View {
        Group {
            if let _ = clerk.user {
                MainView()
            } else {
                AuthView()
            }
        }
    }
}


struct MainView: View {
    @Environment(\.clerk) private var clerk

    // MODIFIED: Game Cards with iconName removed from initializer
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

    // Define grid layout: 2 columns with adaptive sizing
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Keep VStack for overall structure
                
                // Top Header (Mimicking Liquipedia's top bar)
                HStack {
                    Spacer()
                    Text("eClips: Esports Hub")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.8)) // Darker header
                
                // Main Scrollable Content Area with Game Cards
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(gameCards) { card in
                            NavigationLink(destination: card.destination) {
                                GameCardView(card: card)
                            }
                            .buttonStyle(PlainButtonStyle()) // Remove default button styling
                        }
                    }
                    .padding() // Padding around the grid
                }
                .background(Color(red: 0.1, green: 0.1, blue: 0.1)) // Darker background for the content
            }
            .navigationBarHidden(true) // Hide the default navigation bar for custom header
            .background(Color.black.edgesIgnoringSafeArea(.all)) // Overall black background
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
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
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure proper navigation stack on iPad
    }
}

// MARK: - GameCardView (New Custom View for Each Game Card)
struct GameCardView: View {
    let card: GameCard

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack(alignment: .topTrailing) {
                // Card background image
                Image(card.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120) // Fixed height for the image area
                    .clipped()
                    .cornerRadius(8) // Rounded corners for the image
                
                if card.name == "Overwatch 2" { // Example for "NEW" tag like in Liquipedia
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
                // REMOVED: The logic to display card.iconName is gone.
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
        .background(Color(red: 0.15, green: 0.15, blue: 0.15)) // Card background color
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
