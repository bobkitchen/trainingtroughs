//  OpenAIResponse.swift
//  TrainingTroughs
//
//  Created by ChatGPT on 4/18/25.
//

import Foundation

struct OpenAIResponse: Decodable {
  let id: String
  let object: String
  let created: Int
  let choices: [Choice]

  struct Choice: Decodable {
    let text: String
    let index: Int
  }
}
