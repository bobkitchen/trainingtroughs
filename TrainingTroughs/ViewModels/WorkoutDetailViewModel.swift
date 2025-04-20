//
//  WorkoutDetailViewModel.swift
//  TrainingTroughs
//

import Foundation
import SwiftUI

@MainActor
final class WorkoutDetailViewModel: ObservableObject {

    // MARK: published state
    @Published var activity: Workout
    @Published var detail  : ActivityDetail?

    // MARK: dependency
    private let service: IntervalsAPIService

    // designated initializer (used by previews/tests)
    init(activity: Workout, service: IntervalsAPIService) {
        self.activity = activity
        self.service  = service
    }

    // convenience for main app
    convenience init(activity: Workout) {
        self.init(activity: activity, service: .shared)     // ← uses singleton
    }

    // MARK: Public
    func load() async {
        do {
            detail = try await service.fetchActivityDetail(id: activity.id)
        } catch {
            print("⚠️ Activity‑detail fetch failed:", error)
        }
    }
}
