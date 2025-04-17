//
//  TrainingTroughsApp.swift
//  TrainingTroughs
//
//  Created by Bob Kitchen on 4/17/25.
//

import SwiftUI

@main
struct TrainingTroughsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
