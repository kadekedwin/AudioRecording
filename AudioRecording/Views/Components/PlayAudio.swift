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
    
    let formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    return formattedTime
}

struct PlayAudio: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Audio.timestamp, ascending: true)],
        animation: .default)
    private var audios: FetchedResults<Audio>
    
    @StateObject var audioManager = AudioManager.shared
    
    var body: some View {
        List(audios) { audio in
            VStack(alignment: .leading) {
                Text(audio.name!)
                    .font(.headline)
                HStack {
                    Text(describeDate(audio.timestamp!))
                    Spacer()
                    Text(String(formatTimeFromSeconds(audio.duration)))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .onTapGesture {
                audioManager.startPlaying(at: URL(string: audio.path!)!)
            }
        }
        .listStyle(PlainListStyle())
    }
}

#Preview {
    PlayAudio()
}
