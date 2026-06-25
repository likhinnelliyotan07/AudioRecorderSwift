//
//  RecordingView.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import SwiftUI
import Combine

public struct RecordingView: View {
    @ObservedObject var viewModel: RecordingViewModel
    
    // Waveform simulation heights
    @State private var waveHeights: [CGFloat] = Array(repeating: 10, count: 25)
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    public init(viewModel: RecordingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.03, green: 0.03, blue: 0.05)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header Status
                    VStack(spacing: 8) {
                        Text(viewModel.isRecording ? "RECORDING" : "AUDIO RECORDER")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.isRecording ? .red : .gray)
                            .tracking(2)
                            .padding(.top, 16)
                        
                        Text(formatDuration(viewModel.isRecording ? viewModel.recordingDuration : 0))
                            .font(.system(size: 54, weight: .thin, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 20)

                    // Waveform (Simulated live animation during recording)
                    HStack(spacing: 4) {
                        ForEach(0..<waveHeights.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: viewModel.isRecording ? [.red, .orange] : [.blue, .cyan]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 4, height: waveHeights[index])
                        }
                    }
                    .frame(height: 80)
                    .onReceive(timer) { _ in
                        if viewModel.isRecording {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                for i in 0..<waveHeights.count {
                                    waveHeights[i] = CGFloat.random(in: 10...70)
                                }
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                for i in 0..<waveHeights.count {
                                    let sine = sin(CGFloat(i) * 0.5) * 10 + 20
                                    waveHeights[i] = max(8, sine)
                                }
                            }
                        }
                    }

                    // Record Button Area
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            viewModel.toggleRecording()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(viewModel.isRecording ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
                                .frame(width: 100, height: 100)
                                .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                                .animation(viewModel.isRecording ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: viewModel.isRecording)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: viewModel.isRecording ? [.red, .orange] : [.blue, .cyan]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 76, height: 76)
                                .shadow(color: viewModel.isRecording ? .red.opacity(0.5) : .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            
                            if viewModel.isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            } else {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    .padding(.bottom, 16)

                    // Recordings List
                    VStack(alignment: .leading) {
                        Text("SAVED RECORDINGS")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .tracking(1.5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)

                        if viewModel.recordings.isEmpty {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "mic.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No recordings yet")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                        } else {
                            List {
                                ForEach(viewModel.recordings) { recording in
                                    RecordingRow(
                                        recording: recording,
                                        isPlaying: viewModel.playingRecordingID == recording.id,
                                        onPlayToggle: {
                                            viewModel.togglePlayback(for: recording)
                                        }
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                }
                                .onDelete(perform: viewModel.deleteRecording)
                            }
                            .listStyle(.plain)
                            .background(Color.clear)
                        }
                    }
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
        }
        .preferredColorScheme(.dark)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let hundredths = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, hundredths)
    }
}

struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool
    let onPlayToggle: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onPlayToggle) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.orange.opacity(0.2) : Color.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isPlaying ? .orange : .white)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(recording.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(formatDate(recording.createdAt))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()

            Text(formatDuration(recording.duration))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.cyan)
        }
        .padding(.all, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPlaying ? Color.orange.opacity(0.3) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
