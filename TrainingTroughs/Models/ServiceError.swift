//
//  ServiceError.swift
//  TrainingTroughs
//
//  Defines every error the Intervals ICU service can throw
//

import Foundation

/// A single, canonical definition so we never get a duplicate‑symbol error.
enum ServiceError: Error, LocalizedError {
    case invalidURL, unauthorized, notFound
    case serverError(status: Int)
    case csvParsing
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Bad API URL."
        case .unauthorized:        return "401 – check your API key."
        case .notFound:            return "404 – resource not found."
        case .serverError(let s):  return "Server replied (\(s))."
        case .csvParsing:          return "CSV couldn’t be parsed."
        case .decodingError(let e):return e.localizedDescription
        }
    }
}
