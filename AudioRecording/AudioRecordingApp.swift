//
//  AudioRecordingApp.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 10/09/23.
//

import SwiftUI

@main
struct AudioRecordingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
