//
//  AudioManager.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 14/09/23.
//

import Foundation
import AVFoundation

class AudioManager : ObservableObject {
    static let shared = AudioManager()
    
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    let audioSession = AVAudioSession.sharedInstance()
    
    @Published var isRecording = false
    @Published var isPlaying = false
    
    @Published var audioName: String?
    @Published var audioURL: URL?
    @Published var audioDuration: Double?
    @Published var audioSize: Double?
    
    func startRecording() {
        let audioSettings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)

            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            audioName = "record\(getFileCount(fileExtension: "m4a"))"
            audioURL = documentsDirectory.appendingPathComponent("\(UUID().uuidString).m4a")

            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: audioSettings)
            audioRecorder.prepareToRecord()
            audioRecorder.record()

            isRecording = true
        } catch {
            print("Error setting up recording: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        
        audioDuration = getAudioDuration(at: audioURL!)
        audioSize = getFileSize(at: audioURL!)
        
        isRecording = false
    }

    func startPlaying(at path: URL) {
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Failed to connect speaker")
        }
            
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : path)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            isPlaying = true
                
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(){
        audioPlayer.stop()
        
        isPlaying = false
    }
    
}
