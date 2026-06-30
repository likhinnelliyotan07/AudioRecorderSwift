//
//  RecordingRepositoryProtocol.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public protocol RecordingRepositoryProtocol {
    func fetchRecordings() -> [Recording]
    func saveRecording(_ recording: Recording)
    func deleteRecording(_ recording: Recording)
}
