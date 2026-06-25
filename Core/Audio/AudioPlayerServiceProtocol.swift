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
    func startPlaying(url: URL, onCompletion: @escaping () -> Void) throws
    func stopPlaying()
}
