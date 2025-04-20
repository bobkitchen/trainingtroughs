//
//  FitnessPoint.swift
//  TrainingTroughs
//
//  One daily CTL/ATL/TSB sample for the trend chart.
//

import Foundation

struct FitnessPoint: Identifiable, Codable, Hashable {
    let id   = UUID()
    let date: Date           // ← no default value; Codable can decode
    let ctl : Double
    let atl : Double
    let tsb : Double
}
