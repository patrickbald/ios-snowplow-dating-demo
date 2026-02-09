import Foundation
import SnowplowTracker

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

        public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
                        return true
        }

        public var hashValue: Int {
                        return 0
        }

        public init() {}

        public required init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        if !container.decodeNil() {
                                        throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
                        }
        }

        public func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        try container.encodeNil()
        }
}

class JSONCodingKey: CodingKey {
        let key: String

        required init?(intValue: Int) {
                        return nil
        }

        required init?(stringValue: String) {
                        key = stringValue
        }

        var intValue: Int? {
                        return nil
        }

        var stringValue: String {
                        return key
        }
}

class JSONAny: Codable {

        let value: Any

        static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
                        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
                        return DecodingError.typeMismatch(JSONAny.self, context)
        }

        static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
                        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
                        return EncodingError.invalidValue(value, context)
        }

        static func decode(from container: SingleValueDecodingContainer) throws -> Any {
                        if let value = try? container.decode(Bool.self) {
                                        return value
                        }
                        if let value = try? container.decode(Int64.self) {
                                        return value
                        }
                        if let value = try? container.decode(Double.self) {
                                        return value
                        }
                        if let value = try? container.decode(String.self) {
                                        return value
                        }
                        if container.decodeNil() {
                                        return JSONNull()
                        }
                        throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
                        if let value = try? container.decode(Bool.self) {
                                        return value
                        }
                        if let value = try? container.decode(Int64.self) {
                                        return value
                        }
                        if let value = try? container.decode(Double.self) {
                                        return value
                        }
                        if let value = try? container.decode(String.self) {
                                        return value
                        }
                        if let value = try? container.decodeNil() {
                                        if value {
                                                        return JSONNull()
                                        }
                        }
                        if var container = try? container.nestedUnkeyedContainer() {
                                        return try decodeArray(from: &container)
                        }
                        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                                        return try decodeDictionary(from: &container)
                        }
                        throw decodingError(forCodingPath: container.codingPath)
        }

        static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
                        if let value = try? container.decode(Bool.self, forKey: key) {
                                        return value
                        }
                        if let value = try? container.decode(Int64.self, forKey: key) {
                                        return value
                        }
                        if let value = try? container.decode(Double.self, forKey: key) {
                                        return value
                        }
                        if let value = try? container.decode(String.self, forKey: key) {
                                        return value
                        }
                        if let value = try? container.decodeNil(forKey: key) {
                                        if value {
                                                        return JSONNull()
                                        }
                        }
                        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                                        return try decodeArray(from: &container)
                        }
                        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                                        return try decodeDictionary(from: &container)
                        }
                        throw decodingError(forCodingPath: container.codingPath)
        }

        static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
                        var arr: [Any] = []
                        while !container.isAtEnd {
                                        let value = try decode(from: &container)
                                        arr.append(value)
                        }
                        return arr
        }

        static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
                        var dict = [String: Any]()
                        for key in container.allKeys {
                                        let value = try decode(from: &container, forKey: key)
                                        dict[key.stringValue] = value
                        }
                        return dict
        }

        static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
                        for value in array {
                                        if let value = value as? Bool {
                                                        try container.encode(value)
                                        } else if let value = value as? Int64 {
                                                        try container.encode(value)
                                        } else if let value = value as? Double {
                                                        try container.encode(value)
                                        } else if let value = value as? String {
                                                        try container.encode(value)
                                        } else if value is JSONNull {
                                                        try container.encodeNil()
                                        } else if let value = value as? [Any] {
                                                        var container = container.nestedUnkeyedContainer()
                                                        try encode(to: &container, array: value)
                                        } else if let value = value as? [String: Any] {
                                                        var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                                                        try encode(to: &container, dictionary: value)
                                        } else {
                                                        throw encodingError(forValue: value, codingPath: container.codingPath)
                                        }
                        }
        }

        static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
                        for (key, value) in dictionary {
                                        let key = JSONCodingKey(stringValue: key)!
                                        if let value = value as? Bool {
                                                        try container.encode(value, forKey: key)
                                        } else if let value = value as? Int64 {
                                                        try container.encode(value, forKey: key)
                                        } else if let value = value as? Double {
                                                        try container.encode(value, forKey: key)
                                        } else if let value = value as? String {
                                                        try container.encode(value, forKey: key)
                                        } else if value is JSONNull {
                                                        try container.encodeNil(forKey: key)
                                        } else if let value = value as? [Any] {
                                                        var container = container.nestedUnkeyedContainer(forKey: key)
                                                        try encode(to: &container, array: value)
                                        } else if let value = value as? [String: Any] {
                                                        var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                                                        try encode(to: &container, dictionary: value)
                                        } else {
                                                        throw encodingError(forValue: value, codingPath: container.codingPath)
                                        }
                        }
        }

        static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
                        if let value = value as? Bool {
                                        try container.encode(value)
                        } else if let value = value as? Int64 {
                                        try container.encode(value)
                        } else if let value = value as? Double {
                                        try container.encode(value)
                        } else if let value = value as? String {
                                        try container.encode(value)
                        } else if value is JSONNull {
                                        try container.encodeNil()
                        } else {
                                        throw encodingError(forValue: value, codingPath: container.codingPath)
                        }
        }

        public required init(from decoder: Decoder) throws {
                        if var arrayContainer = try? decoder.unkeyedContainer() {
                                        self.value = try JSONAny.decodeArray(from: &arrayContainer)
                        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                                        self.value = try JSONAny.decodeDictionary(from: &container)
                        } else {
                                        let container = try decoder.singleValueContainer()
                                        self.value = try JSONAny.decode(from: container)
                        }
        }

        public func encode(to encoder: Encoder) throws {
                        if let arr = self.value as? [Any] {
                                        var container = encoder.unkeyedContainer()
                                        try JSONAny.encode(to: &container, array: arr)
                        } else if let dict = self.value as? [String: Any] {
                                        var container = encoder.container(keyedBy: JSONCodingKey.self)
                                        try JSONAny.encode(to: &container, dictionary: dict)
                        } else {
                                        var container = encoder.singleValueContainer()
                                        try JSONAny.encode(to: &container, value: self.value)
                        }
        }
}



// MARK: - DatingDemoTabSwitch

/// Track tab navigation
/// Schema: `iglu:com.dating-demo/dating-demo-tab-switch/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoTabSwitch(
///     tabName: tabName
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoTabSwitch {

        /// Name of the tab switched to
        var tabName: TabName

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-tab-switch/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["tab_name"] = tabName.rawValue
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - DatingDemoUser

/// User context entity attached to events
/// Schema: `iglu:com.dating-demo/dating-demo-user/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoUser(
///     accountType: accountType, 
///     daysSinceRegistration: daysSinceRegistration, 
///     isVerified: isVerified, 
///     profileCompletionPct: profileCompletionPct, 
///     userID: userID
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoUser {

        /// User subscription tier
        var accountType: AccountType
        /// Days since user registered
        var daysSinceRegistration: Int?
        /// Whether user has verified their profile
        var isVerified: Bool?
        /// Profile completion percentage
        var profileCompletionPct: Int?
        /// Unique user identifier
        var userID: String

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-user/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["account_type"] = accountType.rawValue
                if let daysSinceRegistration = daysSinceRegistration {
                        payload["days_since_registration"] = daysSinceRegistration
                }
                if let isVerified = isVerified {
                        payload["is_verified"] = isVerified
                }
                if let profileCompletionPct = profileCompletionPct {
                        payload["profile_completion_pct"] = profileCompletionPct
                }
                payload["user_id"] = userID
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - DatingDemoMatch

/// Track successful match events
/// Schema: `iglu:com.dating-demo/dating-demo-match/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoMatch(
///     matchedProfileID: matchedProfileID, 
///     matchedProfileName: matchedProfileName
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoMatch {

        /// ID of the profile that matched
        var matchedProfileID: String
        /// Name of the matched profile
        var matchedProfileName: String?

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-match/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["matched_profile_id"] = matchedProfileID
                if let matchedProfileName = matchedProfileName {
                        payload["matched_profile_name"] = matchedProfileName
                }
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - DatingDemoProfileView

/// Track detailed profile view
/// Schema: `iglu:com.dating-demo/dating-demo-profile-view/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoProfileView(
///     profileID: profileID, 
///     profileName: profileName
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoProfileView {

        /// Unique identifier of the viewed profile
        var profileID: String
        /// Display name of the profile
        var profileName: String?

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-profile-view/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["profile_id"] = profileID
                if let profileName = profileName {
                        payload["profile_name"] = profileName
                }
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - DatingDemoButtonClick

/// Track button click/tap interactions
/// Schema: `iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoButtonClick(
///     buttonID: buttonID, 
///     buttonText: buttonText, 
///     screenName: screenName
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoButtonClick {

        /// Unique identifier for the button
        var buttonID: String
        /// Display text of the button
        var buttonText: String?
        /// Screen where the button was tapped
        var screenName: String

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-button-click/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["button_id"] = buttonID
                if let buttonText = buttonText {
                        payload["button_text"] = buttonText
                }
                payload["screen_name"] = screenName
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - DatingDemoProfileSwipe

/// Track profile swipe interactions
/// Schema: `iglu:com.dating-demo/dating-demo-profile-swipe/jsonschema/1-0-0`
///
/// Example:
/// ```swift
/// let data = DatingDemoProfileSwipe(
///     profileID: profileID, 
///     screenName: screenName, 
///     swipeDirection: swipeDirection
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct DatingDemoProfileSwipe {

        /// Unique identifier of the swiped profile
        var profileID: String
        /// Screen where swipe occurred
        var screenName: String?
        /// Direction of the swipe
        var swipeDirection: SwipeDirection

        private var schema: String {
                return "iglu:com.dating-demo/dating-demo-profile-swipe/jsonschema/1-0-0"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["profile_id"] = profileID
                if let screenName = screenName {
                        payload["screen_name"] = screenName
                }
                payload["swipe_direction"] = swipeDirection.rawValue
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - Event Specification

/// Entity schema for referencing an event specification
/// Schema: `iglu:com.snowplowanalytics.snowplow/event_specification/jsonschema/1-0-3`
///
/// Example:
/// ```swift
/// let data = EventSpecification(
///     id: id,
///     name: name,
///     dataProductId: dataProductId,
///     dataProductName: dataProductName,
///     dataProductDomain: dataProductDomain
/// )
/// // Track as an event
/// Snowplow.defaultTracker()?.track(data.toEvent())
/// // Add as an entity to another event
/// let event = ScreenView(name: "Product")
/// event.entities.append(data.toEntity())
/// Snowplow.defaultTracker()?.track(event)
/// ```
struct EventSpecification {

        /// Identifier for the event specification that the event adheres
        var id: String

        /// Name for the event specification that the event adheres to
        var name: String

        /// Identifier for the data product that the event specification belongs to
        var dataProductId: String

        /// Name for the data product that the event specification belongs to
        var dataProductName: String

        /// Domain for the data product that the event specification belongs to
        var dataProductDomain: String?

        private var schema: String {
                return "iglu:com.snowplowanalytics.snowplow/event_specification/jsonschema/1-0-3"
        }

        private var payload: [String : Any] {
                var payload: [String : Any] = [:]
                payload["id"] = id
                payload["name"] = name
                payload["data_product_id"] = dataProductId
                payload["data_product_name"] = dataProductName
                if let dataProductDomain = dataProductDomain {
                        payload["data_product_domain"] = dataProductDomain
                }
                return payload
        }

        /// Creates an event instance to be tracked by the tracker.
        func toEvent() -> SelfDescribing {
                return SelfDescribing(schema: schema, payload: payload)
        }

        /// Creates an entity that can be added to events.
        func toEntity() -> SelfDescribingJson {
                return SelfDescribingJson(schema: schema, andData: payload)
        }

}

// MARK: - TabName

/// Name of the tab switched to
enum TabName: String {
        case discover = "discover"
        case matches = "matches"
        case profile = "profile"
}

// MARK: - AccountType

/// User subscription tier
enum AccountType: String {
        case free = "free"
        case premium = "premium"
        case premiumPlus = "premium_plus"
}

// MARK: - SwipeDirection

/// Direction of the swipe
enum SwipeDirection: String {
        case superLike = "super_like"
        case swipeDirectionLeft = "left"
        case swipeDirectionRight = "right"
}

extension DatingDemoTabSwitch {
        /// Creates an event with entities for a TabSwitch event specification.
        /// ID: 206fb327-338c-441c-805a-567fb8f252d8
        /// Example:
        /// ```swift
        /// let data = DatingDemoTabSwitch(...)
        /// let dataDatingDemoUser = DatingDemoUser(...)
        /// let event = data.toTabSwitchSpec(dataDatingDemoUser)
        /// // Track as an event
        /// Snowplow.defaultTracker()?.track(event)
        /// ```
        func toTabSwitchSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
                let event = toEvent()
                let eventSpec = EventSpecification(
                        id: "206fb327-338c-441c-805a-567fb8f252d8",
                        name: "Tab switch",
                        dataProductId: "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
                        dataProductName: "Dating App Demo"
                )
                event.entities.append(entityDatingDemoUser.toEntity())
                event.entities.append(eventSpec.toEntity())
                return event
        }
}

extension DatingDemoMatch {
        /// Creates an event with entities for a Match event specification.
        /// ID: 497bf4c2-3179-48ac-83cf-bc7bd12a4639
        /// Example:
        /// ```swift
        /// let data = DatingDemoMatch(...)
        /// let dataDatingDemoUser = DatingDemoUser(...)
        /// let event = data.toMatchSpec(dataDatingDemoUser)
        /// // Track as an event
        /// Snowplow.defaultTracker()?.track(event)
        /// ```
        func toMatchSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
                let event = toEvent()
                let eventSpec = EventSpecification(
                        id: "497bf4c2-3179-48ac-83cf-bc7bd12a4639",
                        name: "Match",
                        dataProductId: "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
                        dataProductName: "Dating App Demo"
                )
                event.entities.append(entityDatingDemoUser.toEntity())
                event.entities.append(eventSpec.toEntity())
                return event
        }
}

extension DatingDemoProfileView {
        /// Creates an event with entities for a ProfileView event specification.
        /// ID: 72baf962-801a-4fe7-8e55-313732659574
        /// Example:
        /// ```swift
        /// let data = DatingDemoProfileView(...)
        /// let dataDatingDemoUser = DatingDemoUser(...)
        /// let event = data.toProfileViewSpec(dataDatingDemoUser)
        /// // Track as an event
        /// Snowplow.defaultTracker()?.track(event)
        /// ```
        func toProfileViewSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
                let event = toEvent()
                let eventSpec = EventSpecification(
                        id: "72baf962-801a-4fe7-8e55-313732659574",
                        name: "Profile view",
                        dataProductId: "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
                        dataProductName: "Dating App Demo"
                )
                event.entities.append(entityDatingDemoUser.toEntity())
                event.entities.append(eventSpec.toEntity())
                return event
        }
}

extension DatingDemoButtonClick {
        /// Creates an event with entities for a ButtonClick event specification.
        /// ID: 8ee91739-efe7-4bcd-91c9-ae734677aa32
        /// Example:
        /// ```swift
        /// let data = DatingDemoButtonClick(...)
        /// let dataDatingDemoUser = DatingDemoUser(...)
        /// let event = data.toButtonClickSpec(dataDatingDemoUser)
        /// // Track as an event
        /// Snowplow.defaultTracker()?.track(event)
        /// ```
        func toButtonClickSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
                let event = toEvent()
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

extension DatingDemoProfileSwipe {
        /// Creates an event with entities for a ProfileSwipe event specification.
        /// ID: 9b0f84cc-fd66-4029-b436-579d6058782b
        /// Example:
        /// ```swift
        /// let data = DatingDemoProfileSwipe(...)
        /// let dataDatingDemoUser = DatingDemoUser(...)
        /// let event = data.toProfileSwipeSpec(dataDatingDemoUser)
        /// // Track as an event
        /// Snowplow.defaultTracker()?.track(event)
        /// ```
        func toProfileSwipeSpec(_ entityDatingDemoUser: DatingDemoUser) -> SelfDescribing {
                let event = toEvent()
                let eventSpec = EventSpecification(
                        id: "9b0f84cc-fd66-4029-b436-579d6058782b",
                        name: "Profile swipe",
                        dataProductId: "cc74c64e-b8ba-4532-b3f7-0668fbf03186",
                        dataProductName: "Dating App Demo"
                )
                event.entities.append(entityDatingDemoUser.toEntity())
                event.entities.append(eventSpec.toEntity())
                return event
        }
}

