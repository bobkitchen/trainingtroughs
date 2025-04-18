//
//  RootTabView.swift
//  TrainingTroughs
//
//  Dashboard • Workouts (split) • Chat – selection‑binding flow
//

import SwiftUI

struct RootTabView: View {

    @StateObject var dashboardVM:   DashboardViewModel
    @StateObject var workoutListVM: WorkoutListViewModel
    @StateObject var chatVM:        ChatViewModel

    // current row selected in the split view
    @State private var selectedWorkout: Workout?

    var body: some View {
        TabView {

            // Dashboard ----------------------------------------------------
            NavigationStack {
                DashboardView(viewModel: dashboardVM)
            }
            .tabItem { Label("Dashboard", systemImage: "chart.line.uptrend.xyaxis") }

            // Workouts (master–detail) ------------------------------------
            NavigationSplitView {

                WorkoutListView(viewModel: workoutListVM,
                                selection: $selectedWorkout)

            } detail: {

                if let w = selectedWorkout {
                    WorkoutDetailView(workout: w)
                } else {
                    ContentUnavailableView("Select a workout",
                                           systemImage: "figure.walk")
                }
            }
            .navigationSplitViewStyle(.balanced)
            .tabItem { Label("Workouts", systemImage: "figure.walk") }

            // Chat ---------------------------------------------------------
            NavigationStack {
                ChatView(chatVM: chatVM)
            }
            .tabItem { Label("Chat", systemImage: "message") }
        }
    }
}
