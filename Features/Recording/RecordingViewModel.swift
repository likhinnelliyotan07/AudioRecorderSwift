import Foundation
import Combine
import AVFoundation

public class RecordingViewModel: ObservableObject {
    private let recorderService: AudioRecorderServiceProtocol
    private var playerService: AudioPlayerServiceProtocol
    private let repository: RecordingRepositoryProtocol

    @Published public var recordings: [Recording] = []
    @Published public var isRecording = false
    @Published public var isPaused = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var playingRecordingID: UUID?
    @Published public var recordingLevels: [Float] = Array(repeating: 0.05, count: 30)
    @Published public var selectedWaveformAmplitudes: [Float] = []
    
    // Playback state tracking for full player page
    @Published public var selectedRecordingForPlayback: Recording?
    @Published public var isPlaying = false
    @Published public var playbackTime: TimeInterval = 0
    @Published public var playbackDuration: TimeInterval = 0
    @Published public var playbackProgress: Double = 0.0
    @Published public var playbackSpeed: Double = 1.0

    private var timer: AnyCancellable?
    private var playbackTimer: AnyCancellable?
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
            self.isPaused = false
            self.recordingDuration = 0
            self.recordingStartTime = Date()
            self.startTimer()
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    public func pauseRecording() {
        recorderService.pauseRecording()
        isPaused = true
    }

    public func resumeRecording() {
        do {
            try recorderService.resumeRecording()
            isPaused = false
        } catch {
            print("Failed to resume recording: \(error)")
        }
    }

    public func discardRecording() {
        guard let result = recorderService.stopRecording() else { return }
        stopTimer()
        isRecording = false
        isPaused = false
        recordingDuration = 0
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: result.url.path) {
            try? fileManager.removeItem(at: result.url)
        }
    }

    private func stopRecording() {
        guard let result = recorderService.stopRecording() else { return }
        stopTimer()
        isRecording = false
        isPaused = false
        
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
            if playingRecordingID == recording.id || selectedRecordingForPlayback?.id == recording.id {
                stopPlaybackForSelected()
            }
            repository.deleteRecording(recording)
        }
        loadRecordings()
    }

    public func deleteRecording(_ recording: Recording) {
        if playingRecordingID == recording.id || selectedRecordingForPlayback?.id == recording.id {
            stopPlaybackForSelected()
        }
        repository.deleteRecording(recording)
        loadRecordings()
    }

    public func renameRecording(_ recording: Recording, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        var updated = recording
        updated.name = newName
        repository.saveRecording(updated)
        
        // If the renamed recording is currently loaded in the player, update it
        if selectedRecordingForPlayback?.id == recording.id {
            selectedRecordingForPlayback = updated
        }
        loadRecordings()
    }

    public func togglePlayback(for recording: Recording) {
        if playingRecordingID == recording.id {
            if isPlaying {
                pausePlaybackForSelected()
            } else {
                if playbackTime == 0 {
                    startPlayingSelected(recording: recording)
                } else {
                    resumePlaybackForSelected()
                }
            }
        } else {
            startPlayingSelected(recording: recording)
        }
    }

    // MARK: - Selected Playback Controls (Full Player Screen)
    
    public func startPlayingSelected(recording: Recording) {
        stopPlaybackForSelected()
        
        do {
            try playerService.startPlaying(url: recording.fileURL) { [weak self] in
                DispatchQueue.main.async {
                    guard let self = self, self.playingRecordingID == recording.id else { return }
                    self.isPlaying = false
                    self.playbackTime = 0
                    self.playbackProgress = 0.0
                    self.playbackTimer?.cancel()
                    self.playbackTimer = nil
                    self.playingRecordingID = nil
                }
            }
            selectedRecordingForPlayback = recording
            playingRecordingID = recording.id
            isPlaying = true
            playbackDuration = playerService.duration
            playbackTime = 0
            playbackProgress = 0.0
            playbackSpeed = 1.0
            playerService.rate = 1.0
            loadWaveformForSelectedRecording()
            startPlaybackTimer()
        } catch {
            print("Failed to play selected recording: \(error)")
        }
    }
    
    public func loadWaveformForSelectedRecording() {
        guard let recording = selectedRecordingForPlayback else { return }
        AudioWaveformExtractor.extractAmplitudes(from: recording.fileURL, targetCount: 80) { [weak self] amplitudes in
            self?.selectedWaveformAmplitudes = amplitudes
        }
    }
    
    public func selectRecordingForPlayback(_ recording: Recording) {
        if playingRecordingID == recording.id {
            selectedRecordingForPlayback = recording
            loadWaveformForSelectedRecording()
        } else {
            startPlayingSelected(recording: recording)
        }
    }
    
    public func togglePlaybackForSelected() {
        if isPlaying {
            pausePlaybackForSelected()
        } else {
            if playbackTime == 0 {
                if let recording = selectedRecordingForPlayback {
                    startPlayingSelected(recording: recording)
                }
            } else {
                resumePlaybackForSelected()
            }
        }
    }
    
    public func pausePlaybackForSelected() {
        playerService.pausePlaying()
        isPlaying = false
        playbackTimer?.cancel()
        playbackTimer = nil
    }
    
    public func resumePlaybackForSelected() {
        playerService.resumePlaying()
        isPlaying = true
        startPlaybackTimer()
    }
    
    public func stopPlaybackForSelected() {
        playerService.stopPlaying()
        isPlaying = false
        playbackTime = 0
        playbackProgress = 0.0
        playbackTimer?.cancel()
        playbackTimer = nil
        selectedRecordingForPlayback = nil
        playingRecordingID = nil
    }
    
    public func seekPlaybackForSelected(to time: TimeInterval) {
        playerService.seek(to: time)
        playbackTime = time
        if playbackDuration > 0 {
            playbackProgress = time / playbackDuration
        }
    }
    
    public func rewind10Seconds() {
        let newTime = max(0, playerService.currentTime - 10)
        seekPlaybackForSelected(to: newTime)
    }
    
    public func fastForward10Seconds() {
        let newTime = min(playbackDuration, playerService.currentTime + 10)
        seekPlaybackForSelected(to: newTime)
    }
    
    public func toggleSpeed() {
        if playbackSpeed == 1.0 {
            playbackSpeed = 1.5
        } else if playbackSpeed == 1.5 {
            playbackSpeed = 2.0
        } else {
            playbackSpeed = 1.0
        }
        playerService.rate = Float(playbackSpeed)
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.cancel()
        playbackTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.playbackTime = self.playerService.currentTime
                if self.playbackDuration > 0 {
                    self.playbackProgress = self.playbackTime / self.playbackDuration
                }
            }
    }

    private func startTimer() {
        recordingLevels = Array(repeating: 0.05, count: 30)
        
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !self.isPaused {
                    self.recordingDuration += 0.05
                    
                    let amp = self.recorderService.getAmplitude()
                    
                    // Shift array left
                    self.recordingLevels.removeFirst()
                    self.recordingLevels.append(amp)
                }
            }
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}
