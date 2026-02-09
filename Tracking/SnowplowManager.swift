//
//  SnowplowManager.swift
//  SnowplowDatingDemo
//
//  Central manager for Snowplow tracking configuration and event dispatch
//

import Foundation
import SnowplowTracker

final class SnowplowManager {

    // MARK: - Singleton

    static let shared = SnowplowManager()
    private init() {}

    // MARK: - Configuration

    private let collectorEndpoint = "http://localhost:9090"

    /// Unique namespace for this tracker instance
    private let trackerNamespace = "datingDemoTracker"

    /// App identifier
    private let appId = "snowplow-dating-demo"

    // MARK: - Tracker Reference

    private var tracker: TrackerController?

    // MARK: - Initialization

    func initialize() {
        // Network configuration - where events are sent
        let networkConfig = NetworkConfiguration(endpoint: collectorEndpoint)

        // Tracker configuration - what automatic tracking to enable
        let trackerConfig = TrackerConfiguration()
            .appId(appId)
            .sessionContext(true)           // Track session info
            .platformContext(true)          // Track device/OS info
            .applicationContext(true)       // Track app version
            .screenContext(true)            // Attach current screen to events
            .lifecycleAutotracking(true)    // Track app foreground/background
            .screenViewAutotracking(false)  // We'll track screens manually for SwiftUI
            .exceptionAutotracking(true)    // Track crashes
            .installAutotracking(true)      // Track first app open
            .diagnosticAutotracking(true)   // Track internal tracker errors (useful for debugging)

        // Session configuration
        let sessionConfig = SessionConfiguration(
            foregroundTimeout: Measurement(value: 30, unit: .minutes),
            backgroundTimeout: Measurement(value: 30, unit: .minutes)
        )

        // Create the tracker
        tracker = Snowplow.createTracker(
            namespace: trackerNamespace,
            network: networkConfig,
            configurations: [trackerConfig, sessionConfig]
        )

        print("✅ Snowplow tracker initialized with namespace: \(trackerNamespace)")
    }

    // MARK: - Screen View Tracking

    /// Track a screen view event
    func trackScreenView(screenName: String, screenId: UUID = UUID()) {
        let event = ScreenView(name: screenName, screenId: screenId)
        _ = tracker?.track(event)

        print("📱 Tracked screen view: \(screenName)")
    }

    // MARK: - Button/Interaction Tracking

    /// Track a button tap using Snowtype-generated ButtonClick event
    func trackButtonTap(buttonId: String, buttonText: String, screenName: String) {
        let buttonClickData = DatingDemoButtonClick(
            buttonID: buttonId,
            buttonText: buttonText,
            screenName: screenName
        )
        let event = buttonClickData.toButtonClickSpec(currentUserContext())

        _ = tracker?.track(event)

        print("👆 Tracked button tap: \(buttonId) on \(screenName)")
    }

    // MARK: - Dating App Specific Events

    /// Track when user swipes on a profile
    func trackProfileSwipe(profileId: String, direction: UISwipeDirection, screenName: String = "discover") {
        // Map UI swipe direction to Snowtype-generated SwipeDirection
        let snowtypeDirection: SwipeDirection
        switch direction {
        case .left:
            snowtypeDirection = .swipeDirectionLeft
        case .right:
            snowtypeDirection = .swipeDirectionRight
        case .superLike:
            snowtypeDirection = .superLike
        }

        // Build Snowtype-generated event and attach user context + spec
        let swipeData = DatingDemoProfileSwipe(
            profileID: profileId,
            screenName: screenName,
            swipeDirection: snowtypeDirection
        )
        let event = swipeData.toProfileSwipeSpec(currentUserContext())

        _ = tracker?.track(event)

        print("👋 Tracked swipe \(snowtypeDirection.rawValue) on profile: \(profileId)")
    }

    /// Track when user views a profile in detail
    func trackProfileView(profileId: String, profileName: String) {
        let profileViewData = DatingDemoProfileView(
            profileID: profileId,
            profileName: profileName
        )
        let event = profileViewData.toProfileViewSpec(currentUserContext())

        _ = tracker?.track(event)

        print("👀 Tracked profile view: \(profileName)")
    }

    /// Track tab switches in the main navigation
    func trackTabSwitch(tabName: String) {
        guard let tabEnum = TabName(rawValue: tabName) else {
            print("⚠️ Unknown tab name for Snowtype event: \(tabName)")
            return
        }

        let tabData = DatingDemoTabSwitch(tabName: tabEnum)
        let event = tabData.toTabSwitchSpec(currentUserContext())

        _ = tracker?.track(event)

        print("🔀 Tracked tab switch to: \(tabEnum.rawValue)")
    }

    /// Track when a match occurs
    func trackMatch(matchedProfileId: String, matchedProfileName: String) {
        let matchData = DatingDemoMatch(
            matchedProfileID: matchedProfileId,
            matchedProfileName: matchedProfileName
        )
        let event = matchData.toMatchSpec(currentUserContext())

        _ = tracker?.track(event)

        print("💕 Tracked match with: \(matchedProfileName)")
    }

    // MARK: - Structured Event Example

    /// Example of a structured event (simpler but less flexible than self-describing)
    func trackStructuredEvent(category: String, action: String, label: String? = nil) {
        var event = Structured(category: category, action: action)

        if let label = label {
            event = event.label(label)
        }

        _ = tracker?.track(event)

        print("📊 Tracked structured event: \(category)/\(action)")
    }

    // MARK: - Raw Self-Describing (No Snowtype) – Intentionally Failing

    /// Sends a self-describing event using a schema NOT registered in the console.
    /// Uses raw Snowplow API (no Snowtype). Will fail in pipeline/validation.
    func trackUnregisteredSchemaEvent(actionName: String) {
        let payload: [String: Any] = [
            "action_name": actionName,
            "source": "raw_tracker",
            "intentional_failure": true
        ]
        let event = SelfDescribing(
            schema: "iglu:com.dating-demo/unregistered_event/jsonschema/1-0-0",
            payload: payload
        )
        _ = tracker?.track(event)
        print("⚠️ Tracked unregistered schema event (will fail): \(actionName)")
    }
}

// MARK: - Supporting Types

/// Local swipe direction used by the UI, mapped onto Snowtype's `SwipeDirection`.
enum UISwipeDirection {
    case left
    case right
    case superLike
}

extension SnowplowManager {
    /// Builds a demo `DatingDemoUser` context entity for all Snowtype events.
    private func currentUserContext() -> DatingDemoUser {
        DatingDemoUser(
            accountType: .free,
            daysSinceRegistration: nil,
            isVerified: nil,
            profileCompletionPct: nil,
            userID: "demo-user"
        )
    }
}
