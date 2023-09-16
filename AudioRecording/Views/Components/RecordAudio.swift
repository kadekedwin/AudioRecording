//
//  RecordAudio.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 14/09/23.
//

import SwiftUI

struct RecordAudio: View {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    @StateObject var audioManager = AudioManager.shared
    
    var body: some View {
        VStack() {
            if(audioManager.isRecording) {
                Text("Recording...")
                    .padding(.top)
                Circle()
                    .stroke(.gray, lineWidth: 3)
                    .frame(width: 50)
                    .padding()
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 25, height: 25)
                            .foregroundStyle(.red)
                    }
            } else {
                Circle()
                    .stroke(.gray, lineWidth: 3)
                    .frame(width: 50)
                    .padding()
                    .overlay {
                        Circle()
                            .frame(width: 40)
                            .foregroundStyle(.red)
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if(audioManager.isRecording) {
                audioManager.stopRecording()
                persistenceController.addAudio(
                    name: audioManager.audioName!,
                    path: audioManager.audioURL!,
                    duration: audioManager.audioDuration!,
                    size: audioManager.audioSize!,
                    context: viewContext
                )
                dismiss()
            } else {
                audioManager.setupRecording()
                audioManager.startRecording()
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(Divider(), alignment: .top)
    }
}

#Preview {
    RecordAudio()
}
