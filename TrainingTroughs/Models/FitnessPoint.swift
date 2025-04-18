//
//  FitnessPoint.swift
//  TrainingTroughs
//

import Foundation

/// One point on the CTL / ATL / TSB trend returned by Intervals.icu.
struct FitnessPoint: Codable, Identifiable {
    /// `var`, not `let`, so `Codable` can overwrite it when decoding.
    var id = UUID()

    let date: String           // "yyyy-MM-dd"
    let ctl:  Double           // Chronic Training Load
    let atl:  Double           // Acute Training Load
    let tsb:  Double           // Training Stress Balance
}
