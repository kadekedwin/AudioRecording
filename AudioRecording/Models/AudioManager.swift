//
//  AudioManager.swift
//  AudioRecording
//
//  Created by Kadek Edwin on 14/09/23.
//

import Foundation
import AVFoundation

func getAudioDuration(at url: URL) -> Double? {
    let audioAsset = AVURLAsset.init(url: url, options: nil)
    return audioAsset.duration.seconds
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

func getFileCount(fileExtension: String) -> Int {
    var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    let fileManager = FileManager.default
    let fileURLs = try? fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)

    let fileNumbers = fileURLs?
        .filter { $0.pathExtension == "m4a" }
    
    return fileNumbers?.count ?? 0
}

class AudioManager : NSObject, ObservableObject, AVAudioPlayerDelegate {
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
    
    func setupRecording() {
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
            
            audioURL = documentsDirectory.appendingPathComponent("\(UUID().uuidString).m4a")

            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: audioSettings)
            audioRecorder.prepareToRecord()
        } catch {
            print("Error setting up recording: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        audioRecorder.record()
        isRecording = true
    }
    
    func stopRecording() {
        audioRecorder.stop()
        
        audioName = "record\(getFileCount(fileExtension: "m4a"))"
        audioDuration = getAudioDuration(at: audioURL!)
        audioSize = getFileSize(at: audioURL!)
        
        isRecording = false
    }
    

    func setupPlaying(at path: URL) {
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            audioPlayer = try AVAudioPlayer(contentsOf : path)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self // Set the delegate to self
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func startPlaying() {
        audioPlayer.play()
        isPlaying = true
    }
    
    func pausePlaying(){
        audioPlayer.pause()
        isPlaying = false
    }
    
    func stopPlaying(){
        audioPlayer.stop()
        isPlaying = false
    }
    
    
    func getCurrentPlayingTime() -> TimeInterval {
        return audioPlayer.currentTime
    }
    
    func setCurrentPlayingTime(currentTime: TimeInterval) {
        audioPlayer.currentTime = currentTime
    }
    
    func getDuration() -> Double {
        return audioPlayer.duration
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            stopPlaying()
        } else {
            print("Audio playback did not finish successfully.")
        }
    }
}
