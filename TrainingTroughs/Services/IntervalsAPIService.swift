//
//  IntervalsAPIService.swift
//  TrainingTroughs
//
//  FINAL · 19 Apr 2025
//

import Foundation
import SwiftUI   // for @MainActor

// MARK: - Service
@MainActor
final class IntervalsAPIService: ObservableObject {

    // 1. Credentials are pulled from KeychainHelper
    private let apiKey:   String
    private let athleteID:String

    private let baseURL = "https://intervals.icu/api/v1"

    // 2. Singleton (Keychain always succeeds or app fails early)
    static let shared = IntervalsAPIService(
        apiKey:     KeychainHelper.shared.intervalsApiKey ?? "",
        athleteID:  KeychainHelper.shared.athleteID     ?? ""
    )

    // 3. Designated init
    private init(apiKey:String, athleteID:String) {
        self.apiKey    = apiKey
        self.athleteID = athleteID
    }

    // MARK: – Public API  ──────────────────────────────────────────────

    /// One CSV of recent activities (raw text).
    func fetchActivitiesCSV(daysBack: Int = 14) async throws -> String {
        var comps = URLComponents(string: "\(baseURL)/athlete/\(athleteID)/activities.csv")!
        comps.queryItems = [.init(name: "days", value: String(daysBack))]

        let data  = try await request(comps)
        guard let csv = String(data: data, encoding: .utf8) else {
            throw ServiceError.csvParsing
        }
        return csv
    }

    /// Parsed workload models (used by `WorkoutListViewModel`).
    func fetchActivities(daysBack: Int = 14) async throws -> [Workout] {
        let csv   = try await fetchActivitiesCSV(daysBack: daysBack)
        return try CSVWorkoutParser.parse(csv)
    }

    /// CTL/ATL/TSB trend for the last *n* days (used by dashboard).
    func fetchFitnessTrend(days: Int = 90) async throws -> [FitnessPoint] {

        // (a) bucket by calendar‑day
        let workouts = try await fetchActivities(daysBack: days)
        var tssByDay: [Date:Double] = [:]
        for w in workouts {
            let day = Calendar.current.startOfDay(for: w.date)
            tssByDay[day, default: 0] += w.tss
        }

        // (b) exponential moving averages
        let today      = Calendar.current.startOfDay(for: .init())
        let dayArray   = (0..<days).map { Calendar.current.date(byAdding: .day,
                      value: -$0, to: today)! }.reversed()

        let αCTL  = 2.0 / (42.0 + 1.0)
        let αATL  = 2.0 / (7.0  + 1.0)

        var ctl = 0.0, atl = 0.0
        var points: [FitnessPoint] = []

        for day in dayArray {
            let tss = tssByDay[day] ?? 0
            ctl = (tss * αCTL) + (1 - αCTL) * ctl
            atl = (tss * αATL) + (1 - αATL) * atl
            let tsb = ctl - atl
            points.append(FitnessPoint(date: day, ctl: ctl, atl: atl, tsb: tsb))
        }
        return points
    }

    // MARK: – Private plumbing  ───────────────────────────────────────

    /// Performs a GET request with proper authentication.
    private func request(_ comps: URLComponents) async throws -> Data {
        guard let url = comps.url else { throw ServiceError.invalidURL }

        var req = URLRequest(url: url)
        req.setValue(authHeader, forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http  = resp as? HTTPURLResponse else {
            throw ServiceError.invalidURL
        }
        switch http.statusCode {
        case 200: return data
        case 401: throw ServiceError.unauthorized
        case 404: throw ServiceError.notFound
        default:  throw ServiceError.serverError(status: http.statusCode)
        }
    }

    private var authHeader: String {
        let cred = "\(apiKey):\(athleteID)"
        let b64  = Data(cred.utf8).base64EncodedString()
        return "Basic \(b64)"
    }
}

// MARK: – CSV ➜ StreamSet parser  (unchanged)
private extension IntervalsAPIService {

    struct StreamSet: Codable, Hashable {
        let time:   [TimeInterval]
        let hr:     [Int]?
        let power:  [Int]?
    }

    func parseStreams(_ csv: String) -> StreamSet {
        let rows  = csv.split(separator: "\n").map(String.init)
        guard rows.count > 1 else { return StreamSet(time: [], hr: nil, power: nil) }

        let header = rows.first!.split(separator: ",").map(String.init)
        let idx    = Dictionary(uniqueKeysWithValues: header.enumerated().map { ($1, $0) })

        var time: [TimeInterval] = []
        var hr:   [Int]   = []
        var power:[Int]   = []

        for line in rows.dropFirst() {
            let cols = line.split(separator: ",").map(String.init)
            if let i = idx["time"],  let t = Double(cols[i]) { time.append(t) }
            if let i = idx["hr"],    let h = Int(cols[i])    { hr.append(h)   }
            if let i = idx["power"], let p = Int(cols[i])    { power.append(p)}
        }
        // disambiguate ?:
        let hrValues:    [Int]? = hr.isEmpty    ? nil : hr
        let powerValues: [Int]? = power.isEmpty ? nil : power
        return StreamSet(time: time, hr: hrValues, power: powerValues)
    }
}
