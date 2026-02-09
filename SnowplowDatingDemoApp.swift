//
//  SnowplowDatingDemoApp.swift
//  SnowplowDatingDemo
//
//  Demo app showcasing Snowplow iOS Tracker with Snowtype integration
//

import SwiftUI
import SnowplowTracker

@main
struct SnowplowDatingDemoApp: App {

    init() {
        // Initialize Snowplow tracker on app launch
        SnowplowManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
