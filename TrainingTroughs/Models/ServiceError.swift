//
//  ServiceError.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 19 Apr 2025.
//

import Foundation

enum ServiceError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case notFound
    case serverError(status: Int)
    case csvParsing
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                return "The request URL is invalid."
        case .unauthorized:              return "Unauthorized – check your API key."
        case .notFound:                  return "Resource not found."
        case .serverError(let status):   return "Server error (\(status))."
        case .csvParsing:                return "Could not parse CSV."
        case .decodingError(let err):    return "JSON decoding failed: \(err.localizedDescription)"
        }
    }
}
