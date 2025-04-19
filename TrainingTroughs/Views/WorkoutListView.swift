import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutListViewModel

    var body: some View {
        NavigationView {
            List(viewModel.workouts) { workout in
                VStack(alignment: .leading) {
                    Text(workout.name).font(.headline)
                    Text(workout.date, style: .date).font(.subheadline)
                    HStack {
                        Text("TSS: \(workout.tss, specifier: "%.0f")")
                        Text("Dur: \(Int(workout.duration/60)) min")
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("Workouts")
            .task { await viewModel.refresh() }
            .refreshable { await viewModel.refresh() }
        }
    }
}
