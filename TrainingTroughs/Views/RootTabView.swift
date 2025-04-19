//  RootTabView.swift
//  TrainingTroughs
//
<<<<<<< HEAD
//  Dashboard (CTL/ATL), Workouts master–detail, Chat
=======
//  Created by ChatGPT on 4/18/25.
>>>>>>> parent of 73e98e4 (2504182301)
//

import SwiftUI

struct RootTabView: View {
  @StateObject var dashboardVM: DashboardViewModel
  @StateObject var workoutListVM: WorkoutListViewModel
  @StateObject var chatVM: ChatViewModel

<<<<<<< HEAD
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
=======
  var body: some View {
    TabView {
      DashboardView(viewModel: dashboardVM)
        .tabItem { Label("Dashboard", systemImage: "gauge") }
      WorkoutListView(viewModel: workoutListVM)
        .tabItem { Label("Workouts", systemImage: "figure.walk") }
      ChatView(chatVM: chatVM)
        .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right") }
>>>>>>> parent of 73e98e4 (2504182301)
    }
  }
}
