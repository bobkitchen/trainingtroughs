//
//  WorkoutListView.swift
//  TrainingTroughs
//
//  Lists recent workouts and passes selection up to the split‑view.
//  FINAL – 19 Apr 2025
//

import SwiftUI

struct WorkoutListView: View {

    @ObservedObject var viewModel: WorkoutListViewModel         // gets workouts
    @Binding        var selection: Workout?                     // bound to split‑view

    var body: some View {
        List(viewModel.workouts, selection: $selection) { w in
            // Use value‑link so NavigationSplitView can drive the detail pane
            NavigationLink(value: w) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(w.name).font(.headline)
                    Text(w.date, format: .dateTime.year().month().day())
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text("\(Int(w.duration/60)) min • \(Int(w.tss)) TSS")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Workouts")
        // 👉  Fetches the CSV and parses workouts once when the list appears.
        .task {
            await viewModel.refresh()
            print("🔄 WorkoutListView.refresh() complete – \(viewModel.workouts.count) rows")
        }
    }
}
