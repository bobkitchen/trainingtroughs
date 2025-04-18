//  WorkoutDetailView.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import SwiftUI

struct WorkoutDetailView: View {
  let workout: Workout

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text(workout.name).font(.largeTitle)
      Text(workout.date, style: .date)
      Text("Sport: \(workout.sport)")
      Text("Duration: \(Int(workout.duration/60)) minutes")
      Text("TSS: \(workout.tss, specifier: "%.1f")")
      Text("Intensity: \(workout.intensity, specifier: "%.2f")")
      Spacer()
    }
    .padding()
    .navigationTitle("Workout Detail")
  }
}
