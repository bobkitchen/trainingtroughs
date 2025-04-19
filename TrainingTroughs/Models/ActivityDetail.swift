//
//  ActivityDetail.swift
//  TrainingTroughs
//
//  What the `/activity/{id}` endpoint returns – only the fields we need now.
//  Add more as required.
//

import Foundation

struct ActivityDetail: Decodable {
    let id:            String
    let date:          Date
    let sport:         String

    // aggregates
    let avgHr:         Double?
    let maxHr:         Double?
    let avgPower:      Double?
    let maxPower:      Double?

    enum CodingKeys: String, CodingKey {
        case id, sport
        case date        = "start_date_local"
        case avgHr       = "hr_avg"
        case maxHr       = "hr_max"
        case avgPower    = "power_avg"
        case maxPower    = "power_max"
    }
}
