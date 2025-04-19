//
//  IntervalsAPIService.swift
//  TrainingTroughs
//
//  FINAL 19 Apr 2025
//

import Foundation

@MainActor
final class IntervalsAPIService: ObservableObject {
  // ──────────────────────────────────────────────────────────
  //  1. Your credentials (edit these once)
  // ──────────────────────────────────────────────────────────
  private let apiKey:    String
  private let athleteID: String
  private let baseURL    = "https://intervals.icu/api/v1"

  /// Shared singleton
  static let shared = IntervalsAPIService(
    apiKey:    "YOUR-INTERVALS-API-KEY",
    athleteID: "YOUR-ATHLETE-ID"
  )

  private init(apiKey: String, athleteID: String) {
    self.apiKey    = apiKey
    self.athleteID = athleteID
  }

  private var authHeader: String {
    let creds = "\(apiKey):\(athleteID)"
      .data(using: .utf8)!
      .base64EncodedString()
    return "Basic \(creds)"
  }

  // MARK: – Public API

  /// Pull the past `daysBack` days as CSV
  func fetchActivitiesCSV(daysBack: Int = 14) async throws -> String {
    guard var comps = URLComponents(string: "\(baseURL)/activity/csv")
    else { throw ServiceError.invalidURL }

    comps.queryItems = [
      .init(name: "daysBack", value: String(daysBack))
    ]

    let data = try await request(comps)
    guard let csv = String(data: data, encoding: .utf8)
    else { throw ServiceError.csvParsing }
    return csv
  }

  /// Get the detail JSON for one activity
  func fetchActivityDetail(id: String) async throws -> ActivityDetail {
    guard var comps = URLComponents(string: "\(baseURL)/activity/\(id)")
    else { throw ServiceError.invalidURL }

    let data = try await request(comps)
    return try JSONDecoder().decode(ActivityDetail.self, from: data)
  }

  /// Get the time‑series CSV for one activity, parsed into your `StreamSet` model
  func fetchStreams(
    id: String,
    fields: [String] = ["time","hr","power"]
  ) async throws -> StreamSet {
    guard var comps = URLComponents(string: "\(baseURL)/activity/\(id)/streams.csv")
    else { throw ServiceError.invalidURL }

    comps.queryItems = [
      .init(name: "fields", value: fields.joined(separator: ","))
    ]

    let data = try await request(comps)
    guard let csv = String(data: data, encoding: .utf8)
    else { throw ServiceError.csvParsing }

    return parseStreams(csv: csv)
  }

  // MARK: – Private

  private func request(_ comps: URLComponents) async throws -> Data {
    guard let url = comps.url else {
      throw ServiceError.invalidURL
    }
    var req = URLRequest(url: url)
    req.setValue(authHeader, forHTTPHeaderField: "Authorization")

    let (data, resp) = try await URLSession.shared.data(for: req)
    let status = (resp as? HTTPURLResponse)?.statusCode ?? 0

    switch status {
      case 200: break
      case 401: throw ServiceError.unauthorized
      case 404: throw ServiceError.notFound
      default:  throw ServiceError.serverError(status: status)
    }
    return data
  }

  private func parseStreams(csv: String) -> StreamSet {
    let rows = csv
      .split(separator: "\n")
      .map(String.init)

    guard rows.count > 1 else {
      return StreamSet(time: [], hr: nil, power: nil)
    }

    let header = rows[0]
      .split(separator: ",")
      .map(String.init)

    let idx: [String:Int] = Dictionary(
      uniqueKeysWithValues:
        header.enumerated().map { ($1, $0) }
    )

    var timeInts:  [TimeInterval] = []
    var hrInts:    [Int]          = []
    var powerInts:[Int]           = []

    for line in rows.dropFirst() {
      let cols = line
        .split(separator: ",")
        .map(String.init)

      if let ti = idx["time"], let t = Double(cols[ti]) {
        timeInts.append(t)
      }
      if let hi = idx["hr"], let h = Int(cols[hi]) {
        hrInts.append(h)
      }
      if let pi = idx["power"], let p = Int(cols[pi]) {
        powerInts.append(p)
      }
    }

    // Convert Int arrays into Double arrays (your model expects [Double]?)
    let hrValues:    [Double]? = hrInts.isEmpty    ? nil : hrInts.map(Double.init)
    let powerValues: [Double]? = powerInts.isEmpty ? nil : powerInts.map(Double.init)

    return StreamSet(
      time:  timeInts,
      hr:    hrValues,
      power: powerValues
    )
  }
}
