//
//  Utils.swift
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
