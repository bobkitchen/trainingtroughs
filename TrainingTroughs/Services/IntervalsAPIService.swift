//
//  IntervalsAPIService.swift
//  TrainingTroughs
//
//  FINAL • 19 Apr 2025
//
//  – All network calls to Intervals ICU
//  – CSV parsing helpers
//  – Fitness‑trend calculation (CTL / ATL / TSB)
//

import Foundation

// MARK: ‑ Service
@MainActor
final class IntervalsAPIService: ObservableObject {

    // ────────────────────────────────────────────────────────────────
    // 1. Configuration
    // ────────────────────────────────────────────────────────────────
    private let apiKey:    String
    private let athleteID: String

    private let baseURL = "https://intervals.icu/api/v1"

    init(apiKey: String, athleteID: String) {
        self.apiKey     = apiKey
        self.athleteID  = athleteID
    }

    // MARK: ‑ HTTP helper
    private var authHeader: String {
        let cred = "\(apiKey):\(athleteID)"
        let b64  = Data(cred.utf8).base64EncodedString()
        return "Basic \(b64)"
    }

    private func request(_ comps: URLComponents) async throws -> Data {
        guard let url = comps.url else { throw ServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.setValue(authHeader, forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        let status = (resp as? HTTPURLResponse)?.statusCode ?? 0

        switch status {
        case 200: return data
        case 401: throw ServiceError.unauthorized
        case 404: throw ServiceError.notFound
        default:  throw ServiceError.serverError(status: status)
        }
    }

    // ────────────────────────────────────────────────────────────────
    // 2. Public API
    // ────────────────────────────────────────────────────────────────

    /// Raw activities CSV (latest *n* days)
    func fetchActivitiesCSV(daysBack: Int = 14) async throws -> String {
        var comps = URLComponents(string: "\(baseURL)/athlete/\(athleteID)/activities.csv")!
        comps.queryItems = [.init(name: "days", value: String(daysBack))]

        let data = try await request(comps)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw ServiceError.csvParsing
        }
        return csv
    }

    /// Parsed `Workout` models from the same CSV
    func fetchActivities(daysBack: Int = 14) async throws -> [Workout] {
        let csv = try await fetchActivitiesCSV(daysBack: daysBack)
        return try CSVWorkoutParser.parse(csv)
    }

    /// Single‑activity JSON detail
    func fetchActivityDetail(id: String) async throws -> ActivityDetail {
        var comps = URLComponents(string: "\(baseURL)/activity/\(id)")!
        let data  = try await request(comps)
        return try JSONDecoder().decode(ActivityDetail.self, from: data)
    }

    /// Time‑series streams (HR / Power) – already parsed
    func fetchStreams(
        id: String,
        fields: [String] = ["time", "hr", "power"]
    ) async throws -> StreamSet {

        var comps = URLComponents(string: "\(baseURL)/activity/\(id)/streams.csv")!
        comps.queryItems = [.init(name: "fields", value: fields.joined(separator: ","))]

        let data = try await request(comps)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw ServiceError.csvParsing
        }
        return parseStreams(csv)
    }

    /// CTL / ATL / TSB trend (last *n* days, default 90)
    func fetchFitnessTrend(daysBack days: Int = 90) async throws -> [FitnessPoint] {

        // 1. Pull workouts & bucket TSS by calendar‑day
        let workouts  = try await fetchActivities(daysBack: days)
        var tssByDay: [Date: Double] = [:]

        let cal = Calendar.current
        for w in workouts {
            let day = cal.startOfDay(for: w.date)
            tssByDay[day, default: 0] += w.tss
        }

        // 2. Exponential moving averages (42‑day CTL, 7‑day ATL)
        let alphaCTL = 2.0 / (42.0 + 1.0)
        let alphaATL = 2.0 / ( 7.0 + 1.0)

        let today   = cal.startOfDay(for: Date())
        let startDay = cal.date(byAdding: .day, value: -days, to: today)!

        var ctl = 0.0, atl = 0.0, tsb = 0.0
        var points: [FitnessPoint] = []

        var day = startDay
        while day <= today {
            let tss = tssByDay[day, default: 0]
            ctl = (alphaCTL * tss) + ((1 - alphaCTL) * ctl)
            atl = (alphaATL * tss) + ((1 - alphaATL) * atl)
            tsb = ctl - atl

            points.append(FitnessPoint(date: day, ctl: ctl, atl: atl, tsb: tsb))
            day = cal.date(byAdding: .day, value: 1, to: day)!
        }
        return points
    }

    // ────────────────────────────────────────────────────────────────
    // 3. CSV → StreamSet parser (private)
    // ────────────────────────────────────────────────────────────────
    private func parseStreams(_ csv: String) -> StreamSet {
        let rows = csv.split(separator: "\n").map(String.init)
        guard rows.count > 1 else { return StreamSet(time: [], hr: nil, power: nil) }

        let header = rows.first!.split(separator: ",").map(String.init)
        let idx = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($1, $0) })

        var time:  [TimeInterval] = []
        var hr:    [Int]          = []
        var power: [Int]          = []

        for line in rows.dropFirst() {
            let cols = line.split(separator: ",").map(String.init)

            if let ti = idx["time"],  let t = Double(cols[ti])  { time.append(t) }
            if let hi = idx["hr"],    let h = Int(cols[hi])     { hr.append(h) }
            if let pi = idx["power"], let p = Int(cols[pi])     { power.append(p) }
        }

        // disambiguate ?: typed optionals
        let hrValues:    [Int]?    = hr.isEmpty    ? nil : hr
        let powerValues: [Int]?    = power.isEmpty ? nil : power

        return StreamSet(time: time, hr: hrValues, power: powerValues)
    }
}
