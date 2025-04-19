//
//  StreamSet.swift
//  TrainingTroughs
//
//  Created by Bob Kitchen on 4/19/25.
//


//
//  StreamSet.swift
//  TrainingTroughs
//
//  Minimal container for activity streams (time‑series CSV).
//

import Foundation

///  Parallel arrays – `hr` / `power` are *nil* if that stream wasn't requested.
struct StreamSet {
    let time:  [Double]          // seconds since start
    let hr:    [Double]?         // bpm
    let power: [Double]?         // watts
}