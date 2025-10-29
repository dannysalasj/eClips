//
//  OverwatchView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI

struct OverwatchView: View {
    var body: some View {
        ZStack {
            // Background color for the entire view
            Color.orange
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("overwatch2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // Navigation buttons with custom styling
                HStack(spacing: 15) {
                    NavigationLink(destination: OverwatchMatchesView()) {
                        Text("Matches")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchTeamsView()) {
                        Text("Teams")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchNewsView()) {
                        Text("News")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: OverwatchForumsView()) {
                        Text("Forums")
                            .foregroundColor(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.orange.opacity(0.7))
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                Spacer()
                
                // Add more content here
            }
        }
        .navigationBarTitle("Overwatch 2", displayMode: .inline)
        .accentColor(.white)
        .toolbarBackground(Color.orange, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar) // This changes the color of navigation bar buttons
    }
}

// Placeholder views for navigation destinations
struct OverwatchMatchesView: View {
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            Text("Matches Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Matches", displayMode: .inline)
    }
}

struct OverwatchTeamsView: View {
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            Text("Teams Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Teams", displayMode: .inline)
    }
}

struct OverwatchNewsView: View {
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            Text("News Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("News", displayMode: .inline)
    }
}

struct OverwatchForumsView: View {
    var body: some View {
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            Text("Forums Content")
                .foregroundColor(.white)
        }
        .navigationBarTitle("Forums", displayMode: .inline)
    }
}

