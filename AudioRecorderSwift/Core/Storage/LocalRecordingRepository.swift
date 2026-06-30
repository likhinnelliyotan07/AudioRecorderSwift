//
//  LocalRecordingRepository.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation

public class LocalRecordingRepository: RecordingRepositoryProtocol {
    private let userDefaultsKey = "com.audiorecorder.saved_recordings"

    public init() {}

    public func fetchRecordings() -> [Recording] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let recordings = try? JSONDecoder().decode([Recording].self, from: data) else {
            return []
        }
        return recordings.sorted { $0.createdAt > $1.createdAt }
    }

    public func saveRecording(_ recording: Recording) {
        var recordings = fetchRecordings()
        if let index = recordings.firstIndex(where: { $0.id == recording.id }) {
            recordings[index] = recording
        } else {
            recordings.append(recording)
        }
        saveToDisk(recordings)
    }

    public func deleteRecording(_ recording: Recording) {
        var recordings = fetchRecordings()
        recordings.removeAll { $0.id == recording.id }
        saveToDisk(recordings)
        
        // Also delete actual file from disk
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: recording.fileURL.path) {
            try? fileManager.removeItem(at: recording.fileURL)
        }
    }

    private func saveToDisk(_ recordings: [Recording]) {
        if let data = try? JSONEncoder().encode(recordings) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
}
