//  APIError.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import Foundation

/// A generic networking error
enum APIError: Error, LocalizedError {
  case invalidURL
  case requestFailed(underlying: Error)
  case serverError(code: Int)
  case decodingError(underlying: Error)
  case csvParsing
  case accessDenied
  case notFound

  var errorDescription: String? {
    switch self {
    case .invalidURL:                return "Invalid URL."
    case .requestFailed(let e):      return "Request failed: \(e.localizedDescription)"
    case .serverError(let code):     return "Server returned error \(code)."
    case .decodingError(let e):      return "Decoding failed: \(e.localizedDescription)"
    case .csvParsing:                return "CSV parsing failed."
    case .accessDenied:              return "Access denied – check your API key."
    case .notFound:                  return "Resource not found."
    }
  }
}
