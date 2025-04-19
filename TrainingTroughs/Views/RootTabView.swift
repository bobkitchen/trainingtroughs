//
//  RootTabView.swift
//  TrainingTroughs
//
//  Dashboard (CTL/ATL), Workouts master–detail, Chat
//

import SwiftUI

struct RootTabView: View {

    @ObservedObject var dashboardVM  : DashboardViewModel
    @ObservedObject var workoutListVM: WorkoutListViewModel
    @ObservedObject var chatVM       : ChatViewModel        // delete if unused

    // Selection shared by the split view
    @State private var selectedWorkout: Workout?

    var body: some View {
        TabView {

            // ── Dashboard tab ────────────────────────────────────────────────
            NavigationStack {
                DashboardView(viewModel: dashboardVM)
            }
            .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }

            // ── Workouts (master–detail) tab ────────────────────────────────
            NavigationSplitView {

                // Master list
                WorkoutListView(
                    viewModel : workoutListVM,
                    selection : $selectedWorkout
                )

            } detail: {

                // Detail column bound to the same selection
                if let w = selectedWorkout {
                    WorkoutDetailView(workout: w)
                } else {
                    ContentUnavailableView("Select a workout",
                                           systemImage: "figure.walk")
                }
            }
            .navigationSplitViewStyle(.balanced)
            .tabItem { Label("Workouts", systemImage: "list.bullet") }

            // ── Chat tab (optional) ─────────────────────────────────────────
            NavigationStack {
                ChatView(chatVM: chatVM)           // **label is `chatVM` now**
            }
            .tabItem { Label("Chat", systemImage: "message") }
        }
    }
}
