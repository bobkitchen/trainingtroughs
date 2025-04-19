//
//  TrainingTroughsApp.swift
//

import SwiftUI

@main
struct TrainingTroughsApp: App {

    // 1. Shared singletons loaded from Keychain
    private let intervalSvc = IntervalsAPIService(
        apiKey:  KeychainHelper.shared.intervalsAPIKey ?? "",
        athleteID: KeychainHelper.shared.athleteID    ?? ""
    )
    private let openAISvc = OpenAIService(
        apiKey: KeychainHelper.shared.openAIKey ?? ""
    )

    // 2. View‑models (create after services exist)
    @StateObject private var dashboardVM   : DashboardViewModel
    @StateObject private var workoutListVM : WorkoutListViewModel
    @StateObject private var chatVM        : ChatViewModel

    /// Custom init so we can hand the services to the VMs before `@StateObject` wraps them.
    init() {
        _dashboardVM   = StateObject(wrappedValue: DashboardViewModel(service: intervalSvc))
        _workoutListVM = StateObject(wrappedValue: WorkoutListViewModel(service: intervalSvc))
        _chatVM        = StateObject(wrappedValue: ChatViewModel(service: openAISvc))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(
                dashboardVM:   dashboardVM,
                workoutListVM: workoutListVM,
                chatVM:        chatVM
            )
            .environmentObject(intervalSvc)
            .environmentObject(openAISvc)          // remove if Chat dropped
            .sheet(isPresented: $showSettings) {   // edit / validate keys
                SettingsView()
            }
        }
    }

    @State private var showSettings = !KeychainHelper.shared.hasAllKeys
}
