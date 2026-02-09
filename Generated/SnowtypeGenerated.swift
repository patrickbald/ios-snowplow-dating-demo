//
//  SnowtypeGenerated.swift
//  SnowplowDatingDemo
//
//  ⚠️ EXAMPLE FILE - This shows what Snowtype would generate
//  In a real setup, run `snowtype generate` to create this file automatically
//
//  Benefits of generated code:
//  - Type-safe parameters (no typos in dictionary keys)
//  - Compile-time validation
//  - Auto-complete in Xcode
//  - Documentation from schemas
//

import Foundation
import SnowplowTracker

// MARK: - Generated Event Tracking Functions

/// Track a button click event
/// - Parameters:
///   - buttonId: Unique identifier for the button
///   - buttonText: Display text of the button
///   - screenName: Screen where the button was tapped
///   - tracker: Optional tracker instance (uses default if nil)
func trackButtonClick(
    buttonId: String,
    buttonText: String,
    screenName: String,
    tracker: TrackerController? = Snowplow.defaultTracker()
) {
    let data: [String: Any] = [
        "button_id": buttonId,
        "button_text": buttonText,
        "screen_name": screenName
    ]

    let event = SelfDescribing(
        schema: "iglu:com.snowplow.demo/button_click/jsonschema/1-0-0",
        payload: data
    )

    tracker?.track(event)
}

/// Track a profile swipe event
/// - Parameters:
///   - profileId: ID of the profile being swiped
///   - swipeDirection: Direction of swipe (left, right, super_like)
///   - screenName: Screen where swipe occurred
///   - tracker: Optional tracker instance
func trackProfileSwipe(
    profileId: String,
    swipeDirection: ProfileSwipeDirection,
    screenName: String = "discover",
    tracker: TrackerController? = Snowplow.defaultTracker()
) {
    let data: [String: Any] = [
        "profile_id": profileId,
        "swipe_direction": swipeDirection.rawValue,
        "screen_name": screenName
    ]

    let event = SelfDescribing(
        schema: "iglu:com.snowplow.demo/profile_swipe/jsonschema/1-0-0",
        payload: data
    )

    tracker?.track(event)
}

/// Track a profile view event
/// - Parameters:
///   - profileId: ID of the viewed profile
///   - profileName: Name displayed on the profile
///   - tracker: Optional tracker instance
func trackProfileView(
    profileId: String,
    profileName: String,
    tracker: TrackerController? = Snowplow.defaultTracker()
) {
    let data: [String: Any] = [
        "profile_id": profileId,
        "profile_name": profileName
    ]

    let event = SelfDescribing(
        schema: "iglu:com.snowplow.demo/profile_view/jsonschema/1-0-0",
        payload: data
    )

    tracker?.track(event)
}

/// Track a tab switch event
/// - Parameters:
///   - tabName: Name of the tab switched to
///   - tracker: Optional tracker instance
func trackTabSwitch(
    tabName: String,
    tracker: TrackerController? = Snowplow.defaultTracker()
) {
    let data: [String: Any] = [
        "tab_name": tabName
    ]

    let event = SelfDescribing(
        schema: "iglu:com.snowplow.demo/tab_switch/jsonschema/1-0-0",
        payload: data
    )

    tracker?.track(event)
}

/// Track a match event
/// - Parameters:
///   - matchedProfileId: ID of the matched profile
///   - matchedProfileName: Name of the matched profile
///   - tracker: Optional tracker instance
func trackMatch(
    matchedProfileId: String,
    matchedProfileName: String,
    tracker: TrackerController? = Snowplow.defaultTracker()
) {
    let data: [String: Any] = [
        "matched_profile_id": matchedProfileId,
        "matched_profile_name": matchedProfileName
    ]

    let event = SelfDescribing(
        schema: "iglu:com.snowplow.demo/match/jsonschema/1-0-0",
        payload: data
    )

    tracker?.track(event)
}

// MARK: - Generated Enums

/// Valid values for swipe direction
enum ProfileSwipeDirection: String, CaseIterable {
    case left = "left"
    case right = "right"
    case superLike = "super_like"
}

// MARK: - Usage Examples
/*

 Instead of manually constructing events like this:

     let event = SelfDescribing(
         schema: "iglu:com.snowplow.demo/button_click/jsonschema/1-0-0",
         payload: ["button_id": "checkout", "button_text": "Buy Now", "screen_name": "cart"]
     )
     tracker.track(event)

 You can use the generated type-safe function:

     trackButtonClick(
         buttonId: "checkout",
         buttonText: "Buy Now",
         screenName: "cart"
     )

 Benefits:
 - No risk of typos in schema URI or payload keys
 - Compiler enforces required fields
 - Xcode provides auto-complete for parameters
 - Documentation appears in Quick Help

*/
