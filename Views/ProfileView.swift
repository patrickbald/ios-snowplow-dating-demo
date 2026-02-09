//
//  ProfileView.swift
//  SnowplowDatingDemo
//
//  User's own profile - demonstrates settings/profile tracking
//

import SwiftUI

struct ProfileView: View {
    @State private var notificationsEnabled = true
    @State private var locationEnabled = true
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: "person.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Demo User")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("San Francisco, CA")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // Edit Profile Button
                Section {
                    Button {
                        showEditProfile = true

                        // Track button tap
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "edit_profile",
                            buttonText: "Edit Profile",
                            screenName: "profile"
                        )
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Profile")
                        }
                    }
                }

                // Settings Section
                Section("Settings") {
                    Toggle(isOn: $notificationsEnabled) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(.yellow)
                            Text("Notifications")
                        }
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        // Track setting change
                        SnowplowManager.shared.trackStructuredEvent(
                            category: "settings",
                            action: newValue ? "enabled" : "disabled",
                            label: "notifications"
                        )
                    }

                    Toggle(isOn: $locationEnabled) {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.blue)
                            Text("Location Services")
                        }
                    }
                    .onChange(of: locationEnabled) { _, newValue in
                        // Track setting change
                        SnowplowManager.shared.trackStructuredEvent(
                            category: "settings",
                            action: newValue ? "enabled" : "disabled",
                            label: "location"
                        )
                    }
                }

                // Premium Section
                Section("Subscription") {
                    Button {
                        // Track upgrade button tap
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "upgrade_premium",
                            buttonText: "Upgrade to Premium",
                            screenName: "profile"
                        )
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Upgrade to Premium")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Support Section
                Section("Support") {
                    Button {
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "help_center",
                            buttonText: "Help Center",
                            screenName: "profile"
                        )
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Help Center")
                        }
                    }
                    .foregroundColor(.primary)

                    Button {
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "privacy_policy",
                            buttonText: "Privacy Policy",
                            screenName: "profile"
                        )
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Debug: raw Snowplow events (no Snowtype) – schemas not in console, will fail
                Section("Debug – intentional failures") {
                    Button {
                        SnowplowManager.shared.trackUnregisteredSchemaEvent(actionName: "test_unregistered")
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("Fire unregistered schema event")
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Logout
                Section {
                    Button(role: .destructive) {
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "logout",
                            buttonText: "Log Out",
                            screenName: "profile"
                        )
                    } label: {
                        HStack {
                            Spacer()
                            Text("Log Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Track screen view
                SnowplowManager.shared.trackScreenView(screenName: "profile")
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileSheet()
            }
        }
    }
}

// MARK: - Edit Profile Sheet

struct EditProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Edit Profile")
                    .font(.title)

                Text("This is a demo sheet")
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        SnowplowManager.shared.trackButtonTap(
                            buttonId: "edit_profile_done",
                            buttonText: "Done",
                            screenName: "edit_profile"
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                SnowplowManager.shared.trackScreenView(screenName: "edit_profile")
            }
        }
    }
}

#Preview {
    ProfileView()
}
