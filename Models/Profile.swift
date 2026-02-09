//
//  Profile.swift
//  SnowplowDatingDemo
//

import Foundation

struct Profile: Identifiable {
    let id: String
    let name: String
    let age: Int
    let bio: String
    let imageName: String  // SF Symbol for demo purposes

    static let sampleProfiles: [Profile] = [
        Profile(id: "profile_001", name: "Alex", age: 28, bio: "Coffee enthusiast & hiking lover 🏔️", imageName: "person.fill"),
        Profile(id: "profile_002", name: "Jordan", age: 26, bio: "Foodie exploring the city 🍜", imageName: "person.fill"),
        Profile(id: "profile_003", name: "Sam", age: 30, bio: "Dog parent & movie buff 🎬", imageName: "person.fill"),
        Profile(id: "profile_004", name: "Taylor", age: 27, bio: "Yoga instructor & plant mom 🌱", imageName: "person.fill"),
        Profile(id: "profile_005", name: "Casey", age: 29, bio: "Software engineer by day, DJ by night 🎧", imageName: "person.fill"),
    ]
}
