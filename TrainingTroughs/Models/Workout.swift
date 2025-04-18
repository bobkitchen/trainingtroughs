//
//  Workout.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 19 Apr 2025.
//

import Foundation

struct Workout: Identifiable {
    let id:        String
    let date:      Date
    let name:      String
    let sport:     String
    let duration:  TimeInterval   // seconds
    let tss:       Double
    let intensity: Double
}
