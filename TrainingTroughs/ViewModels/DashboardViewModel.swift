//
//  DashboardViewModel.swift
//  TrainingTroughs
//
//  Requests 90 days and skips zero rows.
//  19 Apr 2025
//

import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {

    @Published var fitnessPoints: [FitnessPoint] = []
    @Published var currentCTL:  Double = 0
    @Published var currentATL:  Double = 0
    @Published var currentTSB:  Double = 0
    @Published var errorMessage: String?

    private let service: IntervalsAPIService

    init(service: IntervalsAPIService) {
        self.service = service
    }

    /// Pulls CTL/ATL/TSB history (90 days) and updates UI.
    func refreshFitness(days: Int = 90) async {
        do {
            let points = try await service.fetchFitnessTrend(days: days)
            fitnessPoints = points.reversed()          // oldest‑first for chart

            if let latest = points.first {
                currentCTL = latest.ctl
                currentATL = latest.atl
                currentTSB = latest.tsb
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
