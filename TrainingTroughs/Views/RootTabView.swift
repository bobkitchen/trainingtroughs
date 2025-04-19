//  RootTabView.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import SwiftUI

struct RootTabView: View {
  @StateObject var dashboardVM: DashboardViewModel
  @StateObject var workoutListVM: WorkoutListViewModel
  @StateObject var chatVM: ChatViewModel

  var body: some View {
    TabView {
      DashboardView(viewModel: dashboardVM)
        .tabItem { Label("Dashboard", systemImage: "gauge") }
      WorkoutListView(viewModel: workoutListVM)
        .tabItem { Label("Workouts", systemImage: "figure.walk") }
      ChatView(chatVM: chatVM)
        .tabItem { Label("Coach", systemImage: "bubble.left.and.bubble.right") }
    }
  }
}
