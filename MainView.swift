//
//  ContentView.swift
//  eClips
//
//  Created by Daniel Salas on 5/2/25.
//


import SwiftUI


@main
struct eClipsApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
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
                ToolbarItem(placement: .principal) {
                    Text("eClips")
                        .font(.largeTitle)
                        .foregroundColor(.purple)
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
