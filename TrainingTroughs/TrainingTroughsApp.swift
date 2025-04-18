//
//  TrainingTroughsApp.swift
//  TrainingTroughs
//
//  Clean build – 19 Apr 2025.
//

import SwiftUI

@main
struct TrainingTroughsApp: App {

    // MARK: – View‑model storage
    @StateObject private var dashboardVM:   DashboardViewModel
    @StateObject private var workoutListVM: WorkoutListViewModel
    @StateObject private var chatVM:        ChatViewModel

    init() {
        // One shared Intervals service instance
        let intervalsSvc = IntervalsAPIService()

        // If you still need ChatGPT, keep this line; otherwise delete the whole block
        let openAISvc    = OpenAIService(apiKey:
            "sk‑pro‑LarA7B6ZsZmplbLuR2js1zFYpehSNAw8N5UQA2LbwD~DjZ9qMha9qeOYW3UL1zT3BlbKF3gdeuV‑YTRRf4XtYJyf_E_JB30GQFhSiXFm_N8sxgh_4‑bwKaRUEdDgfgvZAxm0kLq7l9A")

        // Build view‑models with those services
        _dashboardVM   = StateObject(wrappedValue: DashboardViewModel(service: intervalsSvc))
        _workoutListVM = StateObject(wrappedValue: WorkoutListViewModel(service: intervalsSvc))
        _chatVM        = StateObject(wrappedValue: ChatViewModel(service: openAISvc))
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(
                dashboardVM:   dashboardVM,
                workoutListVM: workoutListVM,
                chatVM:        chatVM
            )
        }
    }
}
