//
//  TrainingTroughsApp.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import SwiftUI

@main
struct TrainingTroughsApp: App {

    // ──────────────────────────────────────────────────────────────
    // 1. Shared services ­– instantiated once for the whole app
    // ──────────────────────────────────────────────────────────────
    private let intervalSvc: IntervalsAPIService
    private let openAISvc  : OpenAIService

    // 2. View‑model storage (one instance each)
    @StateObject private var dashboardVM  : DashboardViewModel
    @StateObject private var workoutListVM: WorkoutListViewModel
    @StateObject private var chatVM       : ChatViewModel

    // 3. Init – build services & VM’s, then wrap in @StateObject
    init() {
        intervalSvc = IntervalsAPIService(
            apiKey   : KeychainHelper.shared.intervalsAPIKey ?? "",
            athleteID: KeychainHelper.shared.athleteID       ?? ""
        )
        openAISvc = OpenAIService(
            apiKey: KeychainHelper.shared.openAIKey ?? ""
        )

        _dashboardVM   = StateObject(wrappedValue: DashboardViewModel(service: intervalSvc))
        _workoutListVM = StateObject(wrappedValue: WorkoutListViewModel(service: intervalSvc))
        _chatVM        = StateObject(wrappedValue: ChatViewModel(service: openAISvc))
    }

    // 4. Body
    var body: some Scene {
        WindowGroup {
            RootTabView(
                dashboardVM  : dashboardVM,
                workoutListVM: workoutListVM,
                chatVM       : chatVM
            )
            .environmentObject(intervalSvc)   // sub‑views can reach it
            .environmentObject(openAISvc)
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    // open Settings when no keys yet
    @State private var showSettings = !KeychainHelper.shared.hasAllKeys
}
