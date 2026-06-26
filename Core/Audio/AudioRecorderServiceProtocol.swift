//
//  AudioRecorderServiceProtocol.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public protocol AudioRecorderServiceProtocol {
    var isRecording: Bool { get }
    var isPaused: Bool { get }
    func startRecording() throws -> URL
    func pauseRecording()
    func resumeRecording() throws
    func stopRecording() -> (url: URL, duration: TimeInterval)?
    func getAmplitude() -> Float
}
