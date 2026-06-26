//
//  RecordingViewModel.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import Foundation
import Combine
import AVFoundation

public class RecordingViewModel: ObservableObject {
    private let recorderService: AudioRecorderServiceProtocol
    private let playerService: AudioPlayerServiceProtocol
    private let repository: RecordingRepositoryProtocol

    @Published public var recordings: [Recording] = []
    @Published public var isRecording = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var playingRecordingID: UUID?
    @Published public var recordingLevels: [Float] = Array(repeating: 0.05, count: 30)

    private var timer: AnyCancellable?
    private var recordingStartTime: Date?

    public init(
        recorderService: AudioRecorderServiceProtocol,
        playerService: AudioPlayerServiceProtocol,
        repository: RecordingRepositoryProtocol
    ) {
        self.recorderService = recorderService
        self.playerService = playerService
        self.repository = repository
        loadRecordings()
    }

    public func loadRecordings() {
        self.recordings = repository.fetchRecordings()
    }

    public func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { [weak self] allowed in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if allowed {
                    self.performStartRecording()
                } else {
                    print("Permission to record denied")
                }
            }
        }
        #else
        performStartRecording()
        #endif
    }

    private func performStartRecording() {
        do {
            _ = try self.recorderService.startRecording()
            self.isRecording = true
            self.recordingDuration = 0
            self.recordingStartTime = Date()
            self.startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    private func stopRecording() {
        guard let result = recorderService.stopRecording() else { return }
        stopTimer()
        isRecording = false
        
        let filename = result.url.lastPathComponent
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        let dateString = formatter.string(from: Date())
        let name = "Recording \(dateString)"
        
        let newRecording = Recording(
            filename: filename,
            createdAt: Date(),
            duration: result.duration,
            name: name
        )
        repository.saveRecording(newRecording)
        loadRecordings()
    }

    public func deleteRecording(at offsets: IndexSet) {
        for index in offsets {
            let recording = recordings[index]
            if playingRecordingID == recording.id {
                stopPlaying()
            }
            repository.deleteRecording(recording)
        }
        loadRecordings()
    }

    public func deleteRecording(_ recording: Recording) {
        if playingRecordingID == recording.id {
            stopPlaying()
        }
        repository.deleteRecording(recording)
        loadRecordings()
    }

    public func renameRecording(_ recording: Recording, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        var updated = recording
        updated.name = newName
        repository.saveRecording(updated)
        loadRecordings()
    }

    public func togglePlayback(for recording: Recording) {
        if playingRecordingID == recording.id {
            stopPlaying()
        } else {
            startPlaying(recording: recording)
        }
    }

    private func startPlaying(recording: Recording) {
        do {
            try playerService.startPlaying(url: recording.fileURL) { [weak self] in
                DispatchQueue.main.async {
                    self?.playingRecordingID = nil
                }
            }
            playingRecordingID = recording.id
        } catch {
            print("Failed to play recording: \(error)")
        }
    }

    private func stopPlaying() {
        playerService.stopPlaying()
        playingRecordingID = nil
    }

    private func startTimer() {
        recordingLevels = Array(repeating: 0.05, count: 30)
        
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.recordingDuration = Date().timeIntervalSince(startTime)
                
                let amp = self.recorderService.getAmplitude()
                
                // Shift array left
                self.recordingLevels.removeFirst()
                self.recordingLevels.append(amp)
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
