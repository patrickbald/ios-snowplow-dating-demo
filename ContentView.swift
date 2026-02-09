//
//  ContentView.swift
//  SnowplowDatingDemo
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Discover")
                }
                .tag(0)

            MatchesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Matches")
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
        }
        .tint(.yellow)
        .onChange(of: selectedTab) { _, newValue in
            // Track tab switches
            let tabNames = ["discover", "matches", "profile"]
            SnowplowManager.shared.trackTabSwitch(tabName: tabNames[newValue])
        }
    }
}

#Preview {
    ContentView()
}
