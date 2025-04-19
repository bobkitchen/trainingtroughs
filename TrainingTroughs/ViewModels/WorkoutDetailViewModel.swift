//
//  WorkoutDetailViewModel.swift
//  TrainingTroughs
//
//  Re‑written 19 Apr 2025 – fixes actor‑isolation & duplicate symbol issues
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutDetailViewModel: ObservableObject {

    // MARK: – Published state
    @Published var activity: Workout
    @Published var detail:   ActivityDetail?

    // MARK: – Dependencies
    private let service: IntervalsAPIService

    /// Designated initialiser – inject service (nice for previews / tests)
    init(activity: Workout, service: IntervalsAPIService) {
        self.activity = activity
        self.service  = service
    }

    /// Convenience initialiser – the app will call this one
    convenience init(activity: Workout) {
        self.init(activity: activity, service: .shared)
    }

    // MARK: – Public API
    /// Fetches the per‑activity JSON detail and publishes it.
    func load() async {
        do {
            detail = try await service.fetchActivityDetail(id: activity.id)
        } catch {
            print("⚠️ Activity‑detail fetch failed:", error)
        }
    }
}
