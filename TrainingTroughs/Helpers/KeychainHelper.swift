//
//  KeychainHelper.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import Foundation
import Security

/// Simple Keychain wrapper for three values: Intervals key, Athlete ID, OpenAI key.
class KeychainHelper {
  static let shared = KeychainHelper()
  private init() {}

  private let service = "com.yourcompany.TrainingTroughs"

  private enum Keys: String {
    case intervalsAPIKey, athleteID, openAIKey
  }

  // MARK: – Public accessors

  var intervalsAPIKey: String? {
    get { read(key: .intervalsAPIKey) }
    set { write(key: .intervalsAPIKey, value: newValue) }
  }

  var athleteID: String? {
    get { read(key: .athleteID) }
    set { write(key: .athleteID, value: newValue) }
  }

  var openAIKey: String? {
    get { read(key: .openAIKey) }
    set { write(key: .openAIKey, value: newValue) }
  }

  var hasAllKeys: Bool {
    [intervalsAPIKey, athleteID, openAIKey].allSatisfy { $0?.isEmpty == false }
  }

  // MARK: – Keychain plumbing

  private func write(key: Keys, value: String?) {
    let tag = key.rawValue.data(using: .utf8)!
    // First delete any existing item
    SecItemDelete([
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: service,
      kSecAttrAccount: tag
    ] as CFDictionary)

    guard let s = value, !s.isEmpty,
          let data = s.data(using: .utf8) else { return }

    let add: [String:Any] = [
      kSecClass as String:           kSecClassGenericPassword,
      kSecAttrService as String:     service,
      kSecAttrAccount as String:     tag,
      kSecValueData as String:       data,
      kSecAttrAccessible as String:  kSecAttrAccessibleAfterFirstUnlock
    ]
    SecItemAdd(add as CFDictionary, nil)
  }

  private func read(key: Keys) -> String? {
    let tag = key.rawValue.data(using: .utf8)!
    let query: [String:Any] = [
      kSecClass as String:           kSecClassGenericPassword,
      kSecAttrService as String:     service,
      kSecAttrAccount as String:     tag,
      kSecReturnData as String:      true,
      kSecMatchLimit as String:      kSecMatchLimitOne
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    guard status == errSecSuccess,
          let data = result as? Data,
          let str = String(data: data, encoding: .utf8)
    else { return nil }
    return str
  }
}
