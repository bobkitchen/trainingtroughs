import SwiftUI

@MainActor
final class WorkoutListViewModel: ObservableObject {

    // MARK: – Published state
    @Published var workouts:[Workout] = []
    @Published var errorMessage:String?

    // MARK: – Dependency
    private let service: IntervalsAPIService
    init(service: IntervalsAPIService = .shared) { self.service = service }

    // MARK: – Public API
    func refresh(daysBack: Int = 14) async {
        do {
            let csv     = try await service.fetchActivitiesCSV(daysBack: daysBack)
            let parsed  = try CSVWorkoutParser.parse(csv)
            workouts    = parsed
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
