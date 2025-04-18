//
//  WorkoutListViewModel.swift
//  TrainingTroughs
//
//  Created by You on 19 Apr 2025.
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutListViewModel: ObservableObject {

    @Published var workouts: [Workout] = []
    @Published var errorMessage: String?

    private let service: IntervalsAPIService

    init(service: IntervalsAPIService) {
        self.service = service
    }

    /// Pull workouts from the last *n* days.
    func refresh(daySpan: Int = 7) async {
        do {
            workouts = try await service.fetchRecentWorkouts(daySpan: daySpan)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
