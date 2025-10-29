//
//  RocketLeagueView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

struct RocketLeagueView: View {
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("rocketleague")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: RocketLeagueMatchesView()) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueTeamsView()) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueNewsView()) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: RocketLeagueForumsView()) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Rocket League", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar) // This changes the color of navigation bar buttons
    }
}

// Placeholder views for navigation destinations
struct RocketLeagueMatchesView: View {
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Text("Matches Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Matches", displayMode: .inline)
    }
}

struct RocketLeagueTeamsView: View {
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Text("Teams Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Teams", displayMode: .inline)
    }
}

struct RocketLeagueNewsView: View {
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Text("News Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("News", displayMode: .inline)
    }
}

struct RocketLeagueForumsView: View {
    var body: some View {
        ZStack {
            Color.blue.edgesIgnoringSafeArea(.all)
            Text("Forums Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Forums", displayMode: .inline)
    }
}
