//
//  ContentView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI
import Clerk // <-- ADDED: Import the Clerk SDK


@main
struct eClipsApp: App {

    // ADDED: Create and manage the Clerk shared instance state
    @State private var clerk = Clerk.shared
    
    var body: some Scene {
        WindowGroup {
            // UPDATED: The app's root view is now conditional based on authentication
            ContentView()
                .environment(clerk) // ADDED: Inject the Clerk instance into the environment
                .task {
                    // Configure Clerk with key and load the initial session
                    clerk.configure(publishableKey: "pk_test_Y29tcG9zZWQtcXVldHphbC0yOS5jbGVyay5hY2NvdW50cy5kZXYk")
                    try? await clerk.load()
                }
        }
    }
}

// ADDED: New Root View to Handle Authentication Flow
struct ContentView: View {
    @Environment(\.clerk) private var clerk // Access the injected Clerk instance
    
    var body: some View {
        Group {
            if let _ = clerk.user {
                // User is signed in, show the main content
                MainView()
            } else {
                // User is signed out, present Clerk's authentication flow
                AuthView()
            }
        }
    }
}


struct MainView: View {
    // MODIFIED: Inject the Clerk environment object to access the signOut function
    @Environment(\.clerk) private var clerk

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Made by the eSports community for the eSports community.")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding()
                
                // Game Sections
                List {
                    Section {
                        NavigationLink(destination: OverwatchView()) {
                            HStack {
                                Image("overwatch2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text("Overwatch 2")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(Color(UIColor.orange))
                    }
                    Section {
                        NavigationLink(destination: ValorantView()) {
                            HStack {
                                Image("valorant")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text("Valorant")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(Color(UIColor.red))
                    }
                    Section {
                        NavigationLink(destination: RocketLeagueView()) {
                            HStack {
                                Image("rocketleague")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                Text("Rocket League")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(Color(UIColor.blue))
                    }
                }
                .listStyle(GroupedListStyle())
                .background(Color.black)
                .scrollContentBackground(.hidden)
            }
            .toolbar {
                // Toolbar title (principal placement)
                ToolbarItem(placement: .principal) {
                    Text("eClips")
                        .font(.largeTitle)
                        .foregroundColor(.purple)
                }
                
                // ADDED: Log Out button in the trailing position
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log Out") {
                        // Call the async signOut method
                        Task {
                            do {
                                try await clerk.signOut()
                                // ContentView will automatically switch to AuthView()
                            } catch {
                                print("Error signing out: \(error)")
                            }
                        }
                    }
                    .foregroundColor(.white) // Ensure the button text is visible
                }
            }
            // For iOS 16+ explicitly set toolbar background
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .background(Color.black)
        }
        .background(Color.black)
    }
}
