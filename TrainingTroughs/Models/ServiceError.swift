//
//  ServiceError.swift
//  TrainingTroughs
//
//  Created by Bob Kitchen on 4/19/25.
//


//
//  ServiceError.swift
//  TrainingTroughs
//
//  Defines every error the Intervals.icu service can throw.
//

import Foundation

enum ServiceError: Error, LocalizedError {
    case invalidURL, unauthorized, notFound
    case serverError(status: Int)
    case csvParsing
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:          return "Bad API URL."
        case .unauthorized:        return "401 – check your API key."
        case .notFound:            return "404 – resource not found."
        case .serverError(let s):  return "Server replied (\(s))."
        case .csvParsing:          return "CSV couldn’t be parsed."
        case .decodingError(let e):return e.localizedDescription
        }
    }
}