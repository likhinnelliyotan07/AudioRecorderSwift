//
//  AudioRecorderService.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation
import AVFoundation

public class AudioRecorderService: NSObject, AudioRecorderServiceProtocol, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingStartTime: Date?
    private var recordingURL: URL?

    public var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }

    public func startRecording() throws -> URL {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)
        #endif

        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "recording-\(UUID().uuidString).m4a"
        let fileURL = documentDirectory.appendingPathComponent(filename)
        self.recordingURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: fileURL, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.delegate = self
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        recordingStartTime = Date()

        return fileURL
    }

    public func stopRecording() -> (url: URL, duration: TimeInterval)? {
        guard let recorder = audioRecorder, recorder.isRecording,
              let url = recordingURL, let startTime = recordingStartTime else {
            return nil
        }
        
        recorder.stop()
        let duration = Date().timeIntervalSince(startTime)
        audioRecorder = nil
        recordingStartTime = nil
        recordingURL = nil
        
        return (url, duration)
    }

    public func getAmplitude() -> Float {
        guard let recorder = audioRecorder, recorder.isRecording else { return 0.0 }
        recorder.updateMeters()
        let power = recorder.averagePower(forChannel: 0)
        
        // Map decibels (-60dB to 0dB) to a linear progress (0.0 to 1.0)
        let noiseFloor: Float = -60.0
        if power < noiseFloor {
            return 0.0
        } else if power >= 0.0 {
            return 1.0
        } else {
            let maxAmp = abs(noiseFloor)
            let amp = power + maxAmp
            return amp / maxAmp
        }
    }
}
