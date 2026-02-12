# Snowplow iOS Dating Demo - Snowtype Integration

> **Disclaimer:** This project is not officially supported by Snowplow Analytics. It is provided solely for demonstration and learning purposes. Use at your own discretion.

This demo app showcases how to integrate **Snowtype** into an iOS (SwiftUI) project using the **Snowplow iOS Tracker**. Snowtype generates type-safe Swift structs and enums from your Data Product schemas defined in the Snowplow Console, giving you compile-time validation of your tracking implementation.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
  - [1. Install the Snowplow iOS Tracker](#1-install-the-snowplow-ios-tracker)
  - [2. Install Snowtype CLI](#2-install-snowtype-cli)
  - [3. Configure Snowtype](#3-configure-snowtype)
  - [4. Generate Code](#4-generate-code)
  - [5. Add Generated Files to Your Xcode Project](#5-add-generated-files-to-your-xcode-project)
- [How It Works](#how-it-works)
  - [Tracker Initialization](#tracker-initialization)
  - [Tracking Events with Snowtype](#tracking-events-with-snowtype)
  - [Attaching Context Entities](#attaching-context-entities)
- [Events Tracked in This Demo](#events-tracked-in-this-demo)
- [Project Structure](#project-structure)
- [Regenerating After Schema Changes](#regenerating-after-schema-changes)
- [Snowtype vs Raw SDK](#snowtype-vs-raw-sdk)

---

## Prerequisites

- Xcode 15+
- iOS 15+ deployment target
- A Snowplow Console account with Data Products configured
- A Snowplow Collector endpoint (this demo uses `http://localhost:9090` for local development)
- Node.js (for the Snowtype CLI)

## Project Overview

The app is a mock dating interface with three tabs:

| Tab | Description | Events Tracked |
|-----|-------------|----------------|
| **Discover** | Swipe through profiles | Profile swipes, matches, button taps |
| **Matches** | View matched profiles | Profile views, button taps |
| **Profile** | Account settings | Button taps, settings changes |

All custom events are tracked using **Snowtype-generated structs**, providing compile-time type safety and automatic Event Specification context attachment.

---

## Getting Started

### 1. Install the Snowplow iOS Tracker

Add the Snowplow iOS Tracker to your project via Swift Package Manager:

1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/snowplow/snowplow-ios-tracker`
3. Select the version and add the `SnowplowTracker` product to your target

### 2. Install Snowtype CLI

Install the Snowtype CLI globally via npm:

```bash
npm install -g @snowplow/snowtype
```

### 3. Configure Snowtype

Create a `snowtype.config.json` file in your project root. This file tells Snowtype which Data Products to generate code for, the target tracker, and where to output the generated files.

```json
{
  "igluCentralSchemas": [],
  "dataStructures": [],
  "repositories": [],
  "eventSpecificationIds": [],
  "dataProductIds": [
    "<your-data-product-id>"
  ],
  "organizationId": "<your-organization-id>",
  "tracker": "snowplow-ios-tracker",
  "language": "swift",
  "outpath": "./snowtype"
}
```

| Field | Description |
|-------|-------------|
| `dataProductIds` | Array of Data Product IDs from your Snowplow Console |
| `organizationId` | Your Snowplow Console organization ID |
| `tracker` | Must be `"snowplow-ios-tracker"` for iOS projects |
| `language` | Must be `"swift"` for iOS projects |
| `outpath` | Directory where generated Swift code will be written |

You can also specify individual `eventSpecificationIds` or `dataStructures` if you don't want to pull in an entire Data Product.

### 4. Generate Code

Run the Snowtype CLI to generate your Swift tracking code:

```bash
npx @snowplow/snowtype generate
```

This reads your `snowtype.config.json`, fetches the schemas from Snowplow Console, and generates a Swift file at the configured `outpath` (e.g. `./snowtype/snowplow.swift`).

A `.snowtype-lock.json` file is also created in the output directory to track which event specification versions were used during generation.

### 5. Add Generated Files to Your Xcode Project

After generation, add the output directory (`snowtype/`) to your Xcode project:

1. In Xcode, right-click your project navigator and select **Add Files to "\<Project\>"...**
2. Select the `snowtype/` folder
3. Ensure **"Create folder references"** is selected
4. Confirm the files are added to your app target

The generated `snowplow.swift` file will contain:
- **Structs** for each event and entity defined in your Data Products
- **Enums** for any enumerated fields (e.g. swipe directions, account types)
- **Extension methods** (e.g. `.toButtonClickSpec()`) that wrap each struct into a ready-to-track `SelfDescribing` event with the correct schema and automatically attached Event Specification context

---

## How It Works

### Tracker Initialization

Initialize the Snowplow tracker at app launch. This demo uses a singleton `SnowplowManager`:

```swift
// SnowplowDatingDemoApp.swift
@main
struct SnowplowDatingDemoApp: App {
    init() {
        SnowplowManager.shared.initialize()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

The tracker is configured with your collector endpoint and desired settings:

```swift
func initialize() {
    let networkConfig = NetworkConfiguration(endpoint: "http://localhost:9090")

    let trackerConfig = TrackerConfiguration()
        .appId("snowplow-dating-demo")
        .sessionContext(true)
        .platformContext(true)
        .applicationContext(true)
        .screenContext(true)
        .lifecycleAutotracking(true)
        .screenViewAutotracking(false) // Manual tracking for SwiftUI
        .exceptionAutotracking(true)
        .installAutotracking(true)

    let sessionConfig = SessionConfiguration(
        foregroundTimeout: Measurement(value: 30, unit: .minutes),
        backgroundTimeout: Measurement(value: 30, unit: .minutes)
    )

    tracker = Snowplow.createTracker(
        namespace: "datingDemoTracker",
        network: networkConfig,
        configurations: [trackerConfig, sessionConfig]
    )
}
```

### Tracking Events with Snowtype

With Snowtype, you create event instances using the generated structs and call the generated helper method to produce a trackable event:

```swift
// 1. Create the Snowtype struct with type-safe parameters
let swipeData = DatingDemoProfileSwipe(
    profileID: "user-123",
    screenName: "discover",
    swipeDirection: .swipeDirectionRight  // Type-safe enum
)

// 2. Call the generated helper — attaches schema, Event Specification context, and user entity
let event = swipeData.toProfileSwipeSpec(currentUserContext())

// 3. Track it
tracker.track(event)
```

The generated helper method (`toProfileSwipeSpec`) handles:
- Wrapping the struct data into a `SelfDescribing` event with the correct Iglu schema URI
- Attaching the `EventSpecification` entity (linking back to the spec in Snowplow Console)
- Attaching any context entities you pass in (e.g. the user entity)

### Attaching Context Entities

Snowtype also generates structs for context entities. In this demo, a `DatingDemoUser` entity is attached to every event:

```swift
private func currentUserContext() -> DatingDemoUser {
    DatingDemoUser(
        accountType: .free,         // Enum: .free, .premium, .premium_plus
        daysSinceRegistration: 42,
        isVerified: true,
        profileCompletionPct: 85,
        userID: "user-123"
    )
}
```

Pass it to any Snowtype helper method:

```swift
let event = buttonClickData.toButtonClickSpec(currentUserContext())
```

---

## Events Tracked in This Demo

### Snowtype-Generated Events

| Event | Struct | Fields | Helper Method |
|-------|--------|--------|---------------|
| **Tab Switch** | `DatingDemoTabSwitch` | `tabName` (discover, matches, profile) | `toTabSwitchSpec()` |
| **Profile Swipe** | `DatingDemoProfileSwipe` | `profileID`, `screenName`, `swipeDirection` (left, right, super_like) | `toProfileSwipeSpec()` |
| **Match** | `DatingDemoMatch` | `matchedProfileID`, `matchedProfileName` | `toMatchSpec()` |
| **Profile View** | `DatingDemoProfileView` | `profileID`, `profileName` | `toProfileViewSpec()` |
| **Button Click** | `DatingDemoButtonClick` | `buttonID`, `buttonText`, `screenName` | `toButtonClickSpec()` |

### Context Entity

| Entity | Struct | Fields |
|--------|--------|--------|
| **User** | `DatingDemoUser` | `userID`, `accountType`, `isVerified`, `daysSinceRegistration`, `profileCompletionPct` |

### Other Events (Non-Snowtype)

The demo also includes examples of:
- **Screen Views** — tracked manually per view using the built-in `ScreenView` event
- **Structured Events** — simple category/action/label tracking for settings changes
- **Raw Self-Describing Event** — an intentionally unregistered schema to demonstrate validation failures in the pipeline

---

## Project Structure

```
snowplow-ios-dating-demo-snowtype/
├── SnowplowDatingDemoApp.swift      # App entry point, initializes tracker
├── ContentView.swift                # Tab navigation, tracks tab switches
├── snowtype.config.json             # Snowtype CLI configuration
│
├── snowtype/
│   ├── snowplow.swift               # GENERATED — do not edit manually
│   └── .snowtype-lock.json          # Lock file for event spec versions
│
├── Tracking/
│   └── SnowplowManager.swift        # Singleton tracking manager
│
└── Views/
    ├── DiscoverView.swift           # Swipe UI — tracks swipes, matches
    ├── MatchesView.swift            # Matches list — tracks profile views
    └── ProfileView.swift            # Settings — tracks button taps
```

**Key conventions:**
- All tracking calls go through `SnowplowManager` — views never interact with the tracker directly
- Generated Snowtype code lives in `snowtype/` and should not be edited by hand
- The lock file (`.snowtype-lock.json`) should be committed to source control to track which schema versions were used

---

## Regenerating After Schema Changes

When schemas are updated in the Snowplow Console (e.g. new fields, new events, version bumps), regenerate the tracking code:

```bash
npx @snowplow/snowtype generate
```

This will:
1. Fetch the latest schemas from your configured Data Products
2. Regenerate `snowtype/snowplow.swift` with updated structs/enums
3. Update `.snowtype-lock.json` with the new versions

If a schema change is breaking (e.g. a required field was added), the Swift compiler will surface errors at build time wherever the new field needs to be provided — preventing runtime schema validation failures.

---

## Snowtype vs Raw SDK

| | Snowtype | Raw SDK |
|---|---|---|
| **Schema validation** | Compile-time (Swift type system) | Runtime (pipeline validation) |
| **Event construction** | Generated structs with typed fields | Manual dictionary payloads |
| **Enum values** | Swift enums (autocomplete, exhaustive switch) | Raw strings |
| **Event Specification context** | Automatically attached by helpers | Must be attached manually |
| **Schema URI** | Embedded in generated code | Must be specified as a string |
| **Schema updates** | Regenerate and fix compiler errors | Silent runtime failures possible |

Snowtype is recommended for all production tracking. The raw SDK approach is useful for ad-hoc debugging or tracking events whose schemas are not yet published.
