//
//  WorkoutListViewModel.swift
//  TrainingTroughs
//
//  FINAL – 19 Apr 2025
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutListViewModel: ObservableObject {
  // MARK: – Published state
  @Published var workouts: [Workout] = []
  @Published var errorMessage: String?

  // MARK: – Dependency
  private let service: IntervalsAPIService

  /// Designated initializer – inject your service (for previews/tests too).
  init(service: IntervalsAPIService) {
    self.service = service
  }

  // MARK: – Public API
  /// Pull the last `daysBack` days worth of activities.
  func refresh(daysBack: Int = 14) async {
    do {
      let csv    = try await service.fetchActivitiesCSV(daysBack: daysBack)
      let parsed = try CSVWorkoutParser.parse(csv)
      workouts    = parsed
      errorMessage = nil
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
