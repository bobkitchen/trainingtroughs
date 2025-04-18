//
//  Workout.swift
//  TrainingTroughs
//
//  Simple PO‑model for a single activity.
//

import Foundation

struct Workout: Identifiable, Hashable {          // ← added Hashable
    let id:        String
    let date:      Date
    let name:      String
    let sport:     String
    let duration:  TimeInterval        // seconds
    let tss:       Double
    let intensity: Double
}
