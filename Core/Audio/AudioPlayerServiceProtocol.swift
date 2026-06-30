//
//  AudioPlayerServiceProtocol.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public protocol AudioPlayerServiceProtocol {
    var isPlaying: Bool { get }
    var currentlyPlayingURL: URL? { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var rate: Float { get set }
    func startPlaying(url: URL, onCompletion: @escaping () -> Void) throws
    func pausePlaying()
    func resumePlaying()
    func stopPlaying()
    func seek(to time: TimeInterval)
}
