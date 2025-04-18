//
//  CSVWorkoutParser.swift
//  TrainingTroughs
//
//  Parses Intervals activities.csv into [Workout]   (21 Apr 2025)
//

import Foundation

enum CSVWorkoutParser {

    static func parse(_ csv: String) throws -> [Workout] {

        // strip UTF‑8 BOM if present
        var text = csv
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }

        var lines = text.split(separator:"\n").map(String.init)
        guard !lines.isEmpty else { return [] }

        let header = lines.removeFirst().split(separator:",").map(String.init)
        func col(_ name:String)->Int?{ header.firstIndex(of:name) }

        // mandatory columns
        guard
            let iDate  = col("start_date_local"),
            let iName  = col("name"),
            let iSport = col("type")
        else { throw ServiceError.csvParsing }

        // optional columns
        let iElapsed = col("elapsed_time")
        let iMoving  = col("moving_time")
        let iLoad    = col("icu_training_load")
        let iInt     = col("icu_intensity")

        // formatters
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let plain = DateFormatter()
        plain.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        plain.timeZone   = .current

        func d2(_ s:String) -> Double {
            Double(s.replacingOccurrences(of:",", with:".")) ?? 0
        }

        return lines.compactMap { row -> Workout? in
            let c = row.split(separator:",", omittingEmptySubsequences:false)
                        .map(String.init)
            guard c.count > iSport else { return nil }

            // date
            let dateStr = c[iDate]
            guard let when = iso.date(from: dateStr) ?? plain.date(from: dateStr)
            else { return nil }

            // duration (prefer elapsed_time, else moving_time)
            var dur = 0.0
            if let idx = iElapsed, !c[idx].isEmpty { dur = d2(c[idx]) }
            else if let idx = iMoving, !c[idx].isEmpty { dur = d2(c[idx]) }

            let load = iLoad.map { d2(c[$0]) } ?? 0
            let inten = iInt.map { d2(c[$0]) } ?? 0

            return Workout(
                id:       UUID().uuidString,
                date:     when,
                name:     c[iName],
                sport:    c[iSport],
                duration: TimeInterval(dur),
                tss:      load,
                intensity: inten
            )
        }
    }
}
