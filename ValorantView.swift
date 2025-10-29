//
//  ValorantView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

struct ValorantView: View {
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
    }
    
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.red
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("valorant")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: ValorantMatchesView()) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantTeamsView()) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantNewsView()) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: ValorantForumsView()) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Valorant", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.red, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar) // This changes the color of navigation bar buttons
    }
}

// Placeholder views for navigation destinations
struct ValorantMatchesView: View {
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            Text("Matches Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Matches", displayMode: .inline)
    }
}

struct ValorantTeamsView: View {
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            Text("Teams Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Teams", displayMode: .inline)
    }
}

struct ValorantNewsView: View {
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            Text("News Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("News", displayMode: .inline)
    }
}

struct ValorantForumsView: View {
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.all)
            Text("Forums Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Forums", displayMode: .inline)
    }
}
