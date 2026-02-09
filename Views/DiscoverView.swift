//
//  DiscoverView.swift
//  SnowplowDatingDemo
//
//  Main swiping interface - demonstrates screen view and swipe tracking
//

import SwiftUI

struct DiscoverView: View {
    @State private var profiles = Profile.sampleProfiles
    @State private var currentIndex = 0
    @State private var showMatch = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {
                    if currentIndex < profiles.count {
                        // Profile Card
                        ProfileCardView(profile: profiles[currentIndex])
                            .padding(.horizontal)

                        // Action Buttons
                        HStack(spacing: 40) {
                            // Pass Button
                            ActionButton(
                                systemImage: "xmark",
                                color: .red,
                                size: 60
                            ) {
                                handleSwipe(direction: .left)
                            }

                            // Super Like Button
                            ActionButton(
                                systemImage: "star.fill",
                                color: .blue,
                                size: 50
                            ) {
                                handleSwipe(direction: .superLike)
                            }

                            // Like Button
                            ActionButton(
                                systemImage: "heart.fill",
                                color: .green,
                                size: 60
                            ) {
                                handleSwipe(direction: .right)
                            }
                        }
                        .padding(.bottom, 30)
                    } else {
                        // No more profiles
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)

                            Text("No more profiles!")
                                .font(.title2)
                                .fontWeight(.semibold)

                            Button("Start Over") {
                                currentIndex = 0

                                // Track button tap
                                SnowplowManager.shared.trackButtonTap(
                                    buttonId: "start_over",
                                    buttonText: "Start Over",
                                    screenName: "discover"
                                )
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                        }
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Track screen view when this view appears
                SnowplowManager.shared.trackScreenView(screenName: "discover")
            }
            .alert("It's a Match! 💕", isPresented: $showMatch) {
                Button("Keep Swiping") {
                    // Track button tap
                    SnowplowManager.shared.trackButtonTap(
                        buttonId: "keep_swiping",
                        buttonText: "Keep Swiping",
                        screenName: "match_dialog"
                    )
                }
                Button("Send Message") {
                    // Track button tap
                    SnowplowManager.shared.trackButtonTap(
                        buttonId: "send_message",
                        buttonText: "Send Message",
                        screenName: "match_dialog"
                    )
                }
            }
        }
    }

    private func handleSwipe(direction: UISwipeDirection) {
        guard currentIndex < profiles.count else { return }

        let profile = profiles[currentIndex]

        // Track the swipe event
        SnowplowManager.shared.trackProfileSwipe(
            profileId: profile.id,
            direction: direction
        )

        // Simulate a match on right swipe (50% chance for demo)
        if direction == .right || direction == .superLike {
            if Bool.random() {
                SnowplowManager.shared.trackMatch(
                    matchedProfileId: profile.id,
                    matchedProfileName: profile.name
                )
                showMatch = true
            }
        }

        // Move to next profile
        withAnimation {
            currentIndex += 1
        }
    }
}

// MARK: - Profile Card

struct ProfileCardView: View {
    let profile: Profile

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Image(systemName: profile.imageName)
                    .font(.system(size: 100))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(height: 400)

            // Profile info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(profile.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("\(profile.age)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }

                Text(profile.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let systemImage: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size * 0.4))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(radius: 5)
                )
        }
    }
}

#Preview {
    DiscoverView()
}
