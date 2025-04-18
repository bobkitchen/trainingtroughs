//
//  WorkoutListView.swift
//  TrainingTroughs
//
//  Master list driven by List(selection:).
//

import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var viewModel: WorkoutListViewModel
    @Binding var selection: Workout?                  // split‑view binding

    var body: some View {
        List(selection: $selection) {
            ForEach(viewModel.workouts) { w in
                // ─── row content ─────────────────────────────────────────
                VStack(alignment: .leading, spacing: 2) {
                    Text(w.name).font(.headline)

                    Text(w.date, format: .dateTime.year().month().day())
                        .font(.subheadline).foregroundStyle(.secondary)

                    Text("\(Int(w.duration/60)) min • \(Int(w.tss)) TSS")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                // ─── tag makes the row selectable ───────────────────────
                .tag(w)                                // ← crucial line
            }
        }
        .navigationTitle("Workouts")
        .task { await viewModel.refresh() }
    }
}
