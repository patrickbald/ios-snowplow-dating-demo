# Snowtype vs Raw Snowplow Implementation

This guide walks through the differences between tracking Snowplow events **with Snowtype** (type-safe, generated code) versus **without Snowtype** (raw API calls).

---

## Overview

| Aspect | With Snowtype | Without Snowtype |
|--------|---------------|------------------|
| Type Safety | Compile-time validation | Runtime validation only |
| Schema Sync | Auto-generated from Data Product | Manual schema strings |
| Entity Attachment | Helper methods included | Manual entity creation |
| Refactoring | IDE-assisted | Find-and-replace |
| Setup | Requires `snowtype` CLI | None |

---

## Setup Comparison

### With Snowtype

1. Create a `snowtype.config.json`:

```json
{
  "organizationID": "your-org-id",
  "dataProductIds": ["your-data-product-id"],
  "language": "swift",
  "outpath": "./snowtype"
}
```

2. Run the Snowtype CLI to generate code:

```bash
npx @snowplow/snowtype generate --config snowtype.config.json
```

3. Import the generated file in your project.

### Without Snowtype

No setup required - just use the `SnowplowTracker` SDK directly.

---

## Event Tracking Comparison

### Example 1: Button Click Event

#### With Snowtype

```swift
// Type-safe struct with IDE autocomplete
let buttonClickData = DatingDemoButtonClick(
    buttonID: "upgrade_premium",      // Required - compiler enforces this
    buttonText: "Upgrade to Premium", // Optional
    screenName: "profile"             // Required - compiler enforces this
)

// Helper method attaches user context + event specification automatically
let event = buttonClickData.toButtonClickSpec(currentUserContext())

tracker?.track(event)
```

**What happens under the hood:**
- Schema `iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0` is embedded
- `DatingDemoUser` entity is attached
- `EventSpecification` entity is attached with data product metadata

#### Without Snowtype

```swift
// Manual payload construction - no compile-time validation
let payload: [String: Any] = [
    "button_id": "upgrade_premium",
    "button_text": "Upgrade to Premium",
    "screen_name": "profile"
]

// Must manually specify schema string (typos won't be caught)
let event = SelfDescribing(
    schema: "iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0",
    payload: payload
)

// Must manually attach entities
let userEntity = SelfDescribingJson(
    schema: "iglu:com.dating-demo/dating-demo-user/jsonschema/1-0-0",
    andData: [
        "user_id": "demo-user",
        "account_type": "free"
    ]
)
event.entities.append(userEntity)

tracker?.track(event)
```

---

### Example 2: Profile Swipe Event

#### With Snowtype

```swift
// Enum ensures only valid values are used
let swipeData = DatingDemoProfileSwipe(
    profileID: profile.id,
    screenName: "discover",
    swipeDirection: .swipeDirectionRight  // Type-safe enum
)

let event = swipeData.toProfileSwipeSpec(currentUserContext())
tracker?.track(event)
```

**Benefits:**
- `SwipeDirection` enum only allows `.swipeDirectionLeft`, `.swipeDirectionRight`, or `.superLike`
- Invalid values like `"swiped_right"` or `"LEFT"` are impossible

#### Without Snowtype

```swift
let payload: [String: Any] = [
    "profile_id": profile.id,
    "screen_name": "discover",
    "swipe_direction": "right"  // String - could easily typo as "Right" or "LEFT"
]

let event = SelfDescribing(
    schema: "iglu:com.dating-demo/dating-demo-profile-swipe/jsonschema/1-0-0",
    payload: payload
)

// Manually attach user context
let userEntity = SelfDescribingJson(
    schema: "iglu:com.dating-demo/dating-demo-user/jsonschema/1-0-0",
    andData: ["user_id": "demo-user", "account_type": "free"]
)
event.entities.append(userEntity)

tracker?.track(event)
```

**Risks:**
- Typo in `"swipe_direction"` key won't be caught until pipeline validation
- Wrong enum value like `"Left"` instead of `"left"` fails silently

---

## Structured Events (No Schema)

Structured events are a simpler format that don't require schemas. They're the same with or without Snowtype since they use the built-in Snowplow format.

```swift
// Same implementation regardless of Snowtype
var event = Structured(category: "settings", action: "enabled")
event = event.label("notifications")

tracker?.track(event)
```

**When to use Structured Events:**
- Simple interactions that don't need custom schemas
- Quick prototyping before defining schemas
- Events where category/action/label/property/value are sufficient

**When to use Self-Describing Events:**
- Rich, domain-specific data models
- Events that need entity attachment
- Data that must conform to a defined schema

---

## Entity Attachment Comparison

### With Snowtype

Entities are attached via generated helper methods:

```swift
// Generated extension method handles entity attachment
extension DatingDemoButtonClick {
    func toButtonClickSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
        let event = toEvent()

        // Automatically creates and attaches EventSpecification
        let eventSpec = EventSpecification(
            id: "8ee91739-efe7-4bcd-91c9-ae734677aa32",
            name: "Button click",
            dataProductId: "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
            dataProductName: "Dating App Demo"
        )

        event.entities.append(entityDatingDemoUser.toEntity())
        event.entities.append(eventSpec.toEntity())
        return event
    }
}
```

### Without Snowtype

Manual entity creation and attachment:

```swift
let event = SelfDescribing(
    schema: "iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0",
    payload: ["button_id": "test", "screen_name": "home"]
)

// Manually create user entity
let userEntity = SelfDescribingJson(
    schema: "iglu:com.dating-demo/dating-demo-user/jsonschema/1-0-0",
    andData: [
        "user_id": "demo-user",
        "account_type": "free",
        "is_verified": true,
        "profile_completion_pct": 85
    ]
)

// Manually create event specification entity
let eventSpecEntity = SelfDescribingJson(
    schema: "iglu:com.snowplowanalytics.snowplow/event_specification/jsonschema/1-0-3",
    andData: [
        "id": "8ee91739-efe7-4bcd-91c9-ae734677aa32",
        "name": "Button click",
        "data_product_id": "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
        "data_product_name": "Dating App Demo"
    ]
)

event.entities.append(userEntity)
event.entities.append(eventSpecEntity)

tracker?.track(event)
```

---

## Error Scenarios

### With Snowtype

```swift
// Compile error: Missing argument 'screenName'
let data = DatingDemoButtonClick(
    buttonID: "test",
    buttonText: "Click me"
)

// Compile error: Cannot convert 'String' to 'SwipeDirection'
let swipe = DatingDemoProfileSwipe(
    profileID: "123",
    swipeDirection: "left"  // Error!
)

// Compile error: 'leftt' is not a member of 'SwipeDirection'
let swipe = DatingDemoProfileSwipe(
    profileID: "123",
    swipeDirection: .leftt  // Typo caught!
)
```

### Without Snowtype

```swift
// No compile error - fails at runtime in pipeline
let payload: [String: Any] = [
    "button_id": "test",
    "buton_text": "Click me"  // Typo not caught!
    // Missing "screen_name" - not caught!
]

let event = SelfDescribing(
    schema: "iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0",
    payload: payload
)

tracker?.track(event)  // Sends invalid event to pipeline
```

---

## When to Use Each Approach

### Use Snowtype When:

- You have schemas defined in Snowplow Console/Data Products
- You want compile-time validation
- Multiple developers are implementing tracking
- Events have complex data models
- You want automatic event specification attachment

### Use Raw API When:

- Rapid prototyping before schemas are finalized
- One-off events that don't need schemas
- Testing pipeline validation (intentional failures)
- Simple structured events

---

## Code Organization in This Project

```
snowplow-ios-dating-demo/
├── Tracking/
│   └── SnowplowManager.swift     # Wrapper methods for all tracking
├── snowtype/
│   └── snowplow.swift            # Generated Snowtype code
└── Views/
    ├── DiscoverView.swift        # Calls SnowplowManager methods
    ├── MatchesView.swift
    └── ProfileView.swift
```

### SnowplowManager.swift Patterns

**Snowtype events** (type-safe):
```swift
func trackButtonTap(buttonId: String, buttonText: String, screenName: String) {
    let buttonClickData = DatingDemoButtonClick(
        buttonID: buttonId,
        buttonText: buttonText,
        screenName: screenName
    )
    let event = buttonClickData.toButtonClickSpec(currentUserContext())
    _ = tracker?.track(event)
}
```

**Non-Snowtype events** (raw API):
```swift
func trackStructuredEvent(category: String, action: String, label: String? = nil) {
    var event = Structured(category: category, action: action)
    if let label = label {
        event = event.label(label)
    }
    _ = tracker?.track(event)
}

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
}
```

---

## Summary

| Feature | Snowtype | Raw API |
|---------|----------|---------|
| Type safety | Yes | No |
| IDE autocomplete | Yes | No |
| Compile-time errors | Yes | No |
| Entity helpers | Generated | Manual |
| Schema versioning | Managed | Manual |
| Setup overhead | Moderate | None |
| Flexibility | Constrained to schema | Unlimited |

**Recommendation:** Use Snowtype for production tracking with defined schemas. Use raw API for prototyping or intentional validation testing.
