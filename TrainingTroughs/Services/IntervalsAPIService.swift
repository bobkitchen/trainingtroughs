//
//  IntervalsAPIService.swift
//  TrainingTroughs
//
//  Dashboard + Workouts (matching Intervals header) – 21 Apr 2025
//

import Foundation

@MainActor
final class IntervalsAPIService: ObservableObject {

    private let apiKey  = "f857hjs94nyr5ve33nnm9u3m"
    private let athlete = "i327607"
    private let baseURL = "https://intervals.icu/api/v1"

    private var authHeader: String {
        "Basic " + Data("API_KEY:\(apiKey)".utf8).base64EncodedString()
    }

    // ────────────────────────────────────────────────
    // MARK: Fitness trend (already working)
    // ────────────────────────────────────────────────
    func fetchFitnessTrend(days: Int = 90) async throws -> [FitnessPoint] {
        var comps = URLComponents(
            string:"\(baseURL)/athlete/\(athlete)/wellness.csv")!
        comps.queryItems = [
            .init(name:"fields", value:"date,ctl,atl,tsb"),
            .init(name:"days",   value:"\(days)")
        ]

        let (data, _) = try await request(comps)
        guard let csv = String(data:data, encoding:.utf8) else {
            throw ServiceError.csvParsing
        }
        return try parseWellness(csv)
    }

    // ────────────────────────────────────────────────
    // MARK: Recent workouts (new, working)
    // ────────────────────────────────────────────────
    func fetchRecentWorkouts(daySpan: Int = 7) async throws -> [Workout] {
        var comps = URLComponents(
            string:"\(baseURL)/athlete/\(athlete)/activities.csv")!
        let df = DateFormatter(); df.dateFormat = "yyyy-MM-dd"
        comps.queryItems = [
            .init(name:"oldest",
                  value: df.string(from:
                       Calendar.current.date(byAdding:.day,
                                             value:-daySpan, to:.now)!))
        ]

        let (data, _) = try await request(comps)
        guard let csv = String(data:data, encoding:.utf8) else {
            throw ServiceError.csvParsing
        }
        let items = try CSVWorkoutParser.parse(csv)
        print("🏃‍♂️ parsed \(items.count) workouts")
        return items
    }

    // ────────────────────────────────────────────────
    // MARK: Networking helper
    // ────────────────────────────────────────────────
    private func request(_ comps: URLComponents) async throws -> (Data, HTTPURLResponse){
        var req = URLRequest(url: comps.url!)
        req.setValue(authHeader, forHTTPHeaderField:"Authorization")
        req.setValue("text/csv; charset=utf-8", forHTTPHeaderField:"Accept")
        let (data, resp) = try await URLSession.shared.data(for:req)
        let code = (resp as? HTTPURLResponse)?.statusCode ?? -1
        print("[IntervalsAPI] \(req.url!.lastPathComponent) → \(code)")
        guard code == 200 else {
            if code == 401 { throw ServiceError.unauthorized }
            if code == 404 { throw ServiceError.notFound }
            throw ServiceError.serverError(status: code)
        }
        return (data, resp as! HTTPURLResponse)
    }

    // ────────────────────────────────────────────────
    // MARK: Wellness CSV parser (unchanged)
    // ────────────────────────────────────────────────
    private func parseWellness(_ csv: String) throws -> [FitnessPoint] {
        var text = csv
        if text.hasPrefix("\u{FEFF}") { text.removeFirst() }   // strip BOM
        let rows = text.split(separator:"\n").map(String.init)
        guard rows.count > 1 else { return [] }

        func num(_ s:String)->Double?{
            Double(s.replacingOccurrences(of:",", with:"."))
        }

        return rows.dropFirst().compactMap { row in
            let c = row.split(separator:",").map(String.init)
            guard c.count >= 4,
                  let ctl = num(c[1]), let atl = num(c[2]), let tsb = num(c[3])
            else { return nil }
            return FitnessPoint(date:c[0], ctl:ctl, atl:atl, tsb:tsb)
        }
    }
}
