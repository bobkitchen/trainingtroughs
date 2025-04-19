//
//  TrainingTroughsApp.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import SwiftUI

@main
struct TrainingTroughsApp: App {
  // 1. Shared singletons
  private let intervalsSvc = IntervalsAPIService(
    apiKey: KeychainHelper.shared.intervalsAPIKey ?? "",
    athleteID: KeychainHelper.shared.athleteID      ?? ""
  )
  private let openAISvc   = OpenAIService(
    apiKey: KeychainHelper.shared.openAIKey ?? ""
  )

  // 2. View‑models (created once at launch)
  @StateObject private var dashboardVM     = DashboardViewModel(service: intervalsSvc)
  @StateObject private var workoutListVM   = WorkoutListViewModel(service: intervalsSvc)
  @StateObject private var chatVM          = ChatViewModel(service: openAISvc)

  @State private var showSettings = !KeychainHelper.shared.hasAllKeys

  var body: some Scene {
    WindowGroup {
      RootTabView(
        dashboardVM:   dashboardVM,
        workoutListVM: workoutListVM,
        chatVM:        chatVM
      )
      .environmentObject(intervalsSvc)
      .environmentObject(openAISvc)      // if any sub‑view needs it
      .sheet(isPresented: $showSettings) {
        SettingsView()
      }
    }
  }
}
