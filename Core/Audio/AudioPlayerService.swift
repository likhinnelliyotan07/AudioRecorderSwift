//
//  AudioPlayerService.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation
import AVFoundation

public class AudioPlayerService: NSObject, AudioPlayerServiceProtocol, AVAudioPlayerDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var completionHandler: (() -> Void)?

    public var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }

    public var currentlyPlayingURL: URL? {
        audioPlayer?.url
    }

    public var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }

    public var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }

    public var rate: Float {
        get { audioPlayer?.rate ?? 1.0 }
        set {
            audioPlayer?.enableRate = true
            audioPlayer?.rate = newValue
        }
    }

    public func startPlaying(url: URL, onCompletion: @escaping () -> Void) throws {
        stopPlaying()
        
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
        #endif

        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.enableRate = true
        audioPlayer?.delegate = self
        self.completionHandler = onCompletion
        audioPlayer?.play()
    }

    public func pausePlaying() {
        audioPlayer?.pause()
    }

    public func resumePlaying() {
        audioPlayer?.play()
    }

    public func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        completionHandler?()
        completionHandler = nil
    }

    public func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
    }

    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        completionHandler?()
        completionHandler = nil
        audioPlayer = nil
    }
}
