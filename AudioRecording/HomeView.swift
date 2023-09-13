//
//  ContentView.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 10/09/23.
//

import SwiftUI
import CoreData
import AVFoundation

class AudioManager : ObservableObject {
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    @Published var isRecording = false
    
    var fileNumber = 1
    @Published var fileName: String?
    @Published var recordedAudioURL: URL?
    @Published var duration: Double?
    @Published var fileSize: Double?
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)

            // Define the audio settings
            let audioSettings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            // Create a file URL for the recorded audio
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                fileName = "record\(fileNumber)"
                let audioURL = documentsDirectory.appendingPathComponent("\(fileName).m4a")
                fileNumber += 1

                // Initialize the audio recorder
                audioRecorder = try AVAudioRecorder(url: audioURL, settings: audioSettings)
                audioRecorder?.record()

                withAnimation {
                    isRecording = true
                }
                
                recordedAudioURL = audioURL
            }
        } catch {
            print("Error setting up recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        
        withAnimation {
            isRecording = false
        }
        
        duration = getDuration(at: recordedAudioURL!)
        fileSize = getFileSize(at: recordedAudioURL!)
    }

    func playRecordedAudio(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    
    func getDuration(at url: URL) -> Double? {
        let asset = AVURLAsset(url: url)
        return asset.duration.seconds
    }
    
    func getFileSize(at url: URL) -> Double? {
        var fileSizeInKB: Double?
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            
            if let fileSize = fileAttributes[.size] as? Int64 {
                fileSizeInKB = Double(fileSize) / 1024.0
            }
        } catch {
            print("Error fetching file size: \(error.localizedDescription)")
        }
        
        return fileSizeInKB
    }
}

struct HomeView: View {
    let persistenceController = PersistenceController.shared
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Audio.timestamp, ascending: true)],
        animation: .default)
    private var audios: FetchedResults<Audio>
    
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                List(audios) { audio in
                    VStack(alignment: .leading) {
                        Text(audio.name!)
                            .font(.headline)
                        HStack {
                            Text("Yesterday")
                            Spacer()
                            Text(String(audio.duration))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .onTapGesture {
                        audioManager.playRecordedAudio(at: URL(string: audio.path!)!)
                    }
                }
                .listStyle(PlainListStyle())
                
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
                                    .frame(width: 50, height: 50)
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
                .onTapGesture {
                    if(audioManager.isRecording) {
                        audioManager.stopRecording()
                        persistenceController.addAudio(
                            name: audioManager.fileName!,
                            path: audioManager.recordedAudioURL!, 
                            duration: audioManager.duration!,
                            fileSize: audioManager.fileSize!,
                            context: viewContext
                        )
                        dismiss()
                    } else {
                        audioManager.startRecording()
                    }
                }
                .frame(maxWidth: .infinity)
                .overlay(Divider(), alignment: .top)
                
            }
            .navigationTitle("Saved Audios")
            
        }
        
    }
    
}

#Preview {
    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
