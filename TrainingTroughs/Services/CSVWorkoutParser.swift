//
//  CSVWorkoutParser.swift
//  TrainingTroughs
//
//  Parses activities.csv returned by Intervals.icu
//

import Foundation

enum CSVWorkoutParser {

    /// Convert Intervals activities.csv ➞ [Workout]
    static func parse(_ csv: String) throws -> [Workout] {

        // remove BOM if present
        var txt = csv
        if txt.hasPrefix("\u{FEFF}") { txt.removeFirst() }

        var lines = txt.split(separator:"\n").map(String.init)
        guard !lines.isEmpty else { return [] }

        // delimiter is always ',' for activities.csv
        let header = lines.removeFirst().split(separator:",").map(String.init)
        func col(_ name:String)->Int?{ header.firstIndex(of:name) }

        guard
            let iDate  = col("start_date_local"),
            let iName  = col("name"),
            let iSport = col("type"),              // "Ride","Run", etc.
            let iDur   = col("elapsed_time"),      // seconds
            let iLoad  = col("icu_training_load"),
            let iInt   = col("icu_intensity")
        else { throw ServiceError.csvParsing }

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return lines.compactMap { row -> Workout? in
            let c = row.split(separator:",", omittingEmptySubsequences:false)
                        .map(String.init)
            guard c.count > max(iDate,iName,iSport,iDur,iLoad,iInt) else { return nil }
            guard let when = iso.date(from:c[iDate]) else { return nil }

            return Workout(
                id:       UUID().uuidString,
                date:     when,
                name:     c[iName],
                sport:    c[iSport],
                duration: TimeInterval(Double(c[iDur]) ?? 0),
                tss:      Double(c[iLoad]) ?? 0,   // Intervals calls it "training load"
                intensity: Double(c[iInt]) ?? 0
            )
        }
    }
}
