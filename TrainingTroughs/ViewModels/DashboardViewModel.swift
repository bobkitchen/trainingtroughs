import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: – Published state
    @Published var fitnessPoints:[FitnessPoint] = []
    @Published var currentCTL : Double = 0
    @Published var currentATL : Double = 0
    @Published var currentTSB : String = "0"

    // MARK: – Dependency
    private let service: IntervalsAPIService
    init(service: IntervalsAPIService = .shared) { self.service = service }

    // MARK: – Public API
    func refreshFitness(days: Int = 90) async {
        do {
            let points = try await service.fetchFitnessTrend(days: days)
            fitnessPoints = points.reversed()          // oldest‑first for chart

            if let latest = points.first {
                currentCTL = latest.ctl
                currentATL = latest.atl
                currentTSB = String(format: "%.1f", latest.tsb)
            }
        } catch {
            print("⚠️ Dashboard refresh failed:", error)
        }
    }
}
