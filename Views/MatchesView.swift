//
//  MatchesView.swift
//  SnowplowDatingDemo
//
//  Displays user's matches - demonstrates list interaction tracking
//

import SwiftUI

struct MatchesView: View {
    // Sample matches for demo
    @State private var matches = [
        Profile.sampleProfiles[0],
        Profile.sampleProfiles[2]
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                if matches.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text("No matches yet")
                            .font(.title2)
                            .foregroundColor(.secondary)

                        Text("Keep swiping to find your match!")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(matches) { match in
                        MatchRowView(profile: match)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                // Track profile view from matches list
                                SnowplowManager.shared.trackProfileView(
                                    profileId: match.id,
                                    profileName: match.name
                                )

                                // Track button tap for conversation start
                                SnowplowManager.shared.trackButtonTap(
                                    buttonId: "match_row_tap",
                                    buttonText: "Open Conversation",
                                    screenName: "matches"
                                )
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Track screen view
                SnowplowManager.shared.trackScreenView(screenName: "matches")
            }
        }
    }
}

// MARK: - Match Row

struct MatchRowView: View {
    let profile: Profile

    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: profile.imageName)
                    .font(.title)
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.name)
                    .font(.headline)

                Text("Tap to start chatting")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Unread indicator (demo)
            Circle()
                .fill(.yellow)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }
}

#Preview {
    MatchesView()
}
