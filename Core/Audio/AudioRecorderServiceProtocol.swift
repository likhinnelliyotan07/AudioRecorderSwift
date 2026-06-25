//
//  AudioRecorderServiceProtocol.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public protocol AudioRecorderServiceProtocol {
    var isRecording: Bool { get }
    func startRecording() throws -> URL
    func stopRecording() -> (url: URL, duration: TimeInterval)?
}
