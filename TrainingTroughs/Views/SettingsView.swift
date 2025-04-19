//
//  SettingsView.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import SwiftUI

struct SettingsView: View {
  @State private var intervalsKey: String = KeychainHelper.shared.intervalsAPIKey ?? ""
  @State private var athleteID: String    = KeychainHelper.shared.athleteID     ?? ""
  @State private var openAIKey: String    = KeychainHelper.shared.openAIKey      ?? ""

  var body: some View {
    NavigationView {
      Form {
        Section("Intervals ICU") {
          TextField("API Key", text: $intervalsKey)
          TextField("Athlete ID", text: $athleteID)
        }

        Section("OpenAI (completions)") {
          TextField("API Key", text: $openAIKey)
        }
      }
      .navigationTitle("Settings")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            KeychainHelper.shared.intervalsAPIKey = intervalsKey.trimmingCharacters(in: .whitespaces)
            KeychainHelper.shared.athleteID      = athleteID.trimmingCharacters(in: .whitespaces)
            KeychainHelper.shared.openAIKey      = openAIKey.trimmingCharacters(in: .whitespaces)
          }
        }
      }
    }
  }
}
