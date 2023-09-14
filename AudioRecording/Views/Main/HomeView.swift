//
//  ContentView.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 10/09/23.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                PlayAudio()
                RecordAudio()
            }
            .navigationTitle("Saved Audios")
        }
    }
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
