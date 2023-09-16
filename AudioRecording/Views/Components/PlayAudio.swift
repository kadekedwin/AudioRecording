//
//  PlayAudio.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 14/09/23.
//

import SwiftUI

func describeDate(_ date: Date) -> String {
    let calendar = Calendar.current
    
    if calendar.isDateInToday(date) {
        return "Today"
    } else if calendar.isDateInYesterday(date) {
        return "Yesterday"
    } else {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy" // Customize the format as needed
        return dateFormatter.string(from: date)
    }
}

func formatTimeFromSeconds(_ seconds: Double) -> String {
    let time = Int(seconds)
    let hours = time / 3600
    let minutes = (time % 3600) / 60
    let seconds = time % 60
    
    let formattedTime = String(format: "%02d.%02d.%02d", hours, minutes, seconds)
    return formattedTime
}

struct PlayAudio: View {
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Audio.timestamp, ascending: true)],
        animation: .default)
    private var audios: FetchedResults<Audio>
    
    @StateObject var audioManager = AudioManager.shared
    
    @State private var selectedAudio: FetchedResults<Audio>.Element?
    
    @State private var currentTime: Double = 0.0
    @State private var timer: Timer!
    
    var body: some View {
        List(audios) { audio in
            VStack(alignment: .center) {
                Text(audio.name!)
                    .frame(maxWidth: .infinity, alignment: .leading )
                    .font(.headline)
                HStack {
                    Text(describeDate(audio.timestamp!))
                    Spacer()
                    Text(String(formatTimeFromSeconds(audio.duration)))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                if(audio == selectedAudio) {
                    Slider(value: $currentTime, in: 0...audio.duration, onEditingChanged: seekAudio)
                        .onAppear (perform: {
                            audioManager.setupPlaying(at: URL(string: audio.path!)!)
                        })
                    
                    if(audioManager.isPlaying) {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 50))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                timer.invalidate()
                                audioManager.pausePlaying()
                            }
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 50))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                                    currentTime = audioManager.getCurrentPlayingTime()
                                    if(currentTime >= audioManager.getDuration()) {
                                        audioManager.stopPlaying()
                                        timer.invalidate()
                                    }
                                }
                                audioManager.startPlaying()
                            }
                    }
                }
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectedAudio = audio
            }
        }
        .listStyle(PlainListStyle())
    }

    // Seek to a specific time in the audio
    private func seekAudio(editing: Bool) {
        if editing {
            if(audioManager.isPlaying) {
                timer.invalidate()
                audioManager.pausePlaying()
            }
        } else {
            audioManager.setCurrentPlayingTime(currentTime: currentTime)
        }
    }
}

#Preview {
    PlayAudio()
}
