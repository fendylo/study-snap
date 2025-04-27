//
//  UserDefaultsUtil.swift
//  StudySnap
//
//  Created by Fendy Lomanjaya on 25/4/2025.
//

import Foundation

enum UserDefaultUtil {
    
    // MARK: - Store value (Any type)
    static func set<T: Codable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        } else {
            print("❌ Failed to encode value for key: \(key)")
        }
    }

    // MARK: - Retrieve value (Any Codable type)
    static func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: - Remove value
    static func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: - Check if key exists
    static func exists(forKey key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) != nil
    }

    // MARK: - Clear all UserDefaults (⚠️ Use with caution)
    static func clearAll() {
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}
