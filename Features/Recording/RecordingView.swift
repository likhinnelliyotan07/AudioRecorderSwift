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
    @State private var selectedTab: AppTab = .record
    
    // Rename state tracking
    @State private var showRenameSheet = false
    @State private var recordingToRename: Recording?

    public init(viewModel: RecordingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            // Background Dark slate Color
            AppColors.backgroundDark
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main Switcher Content area
                if selectedTab == .record {
                    recordTabContent
                } else {
                    recordingsTabContent
                }
                
                Spacer(minLength: 0)

                // Custom Reusable Tab Bar
                AppTabBar(selectedTab: $selectedTab)
            }
            
            // Rename Bottom Sheet Overlay
            if showRenameSheet {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showRenameSheet = false
                        }
                    }
                    .transition(.opacity)
                
                VStack {
                    Spacer()
                    RenameBottomSheet(
                        currentName: recordingToRename?.name ?? "",
                        onSave: { newName in
                            if let recording = recordingToRename {
                                viewModel.renameRecording(recording, newName: newName)
                            }
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showRenameSheet = false
                            }
                        },
                        onCancel: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showRenameSheet = false
                            }
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Subviews
    
    // Tab View 1: Active record dashboard
    private var recordTabContent: some View {
        VStack(spacing: 24) {
            // Header Status
            VStack(spacing: 8) {
                Text(viewModel.isRecording ? AppStrings.headerRecording : AppStrings.headerDefault)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.isRecording ? .red : .gray)
                    .tracking(2)
                    .padding(.top, 16)
                
                Text(formatDuration(viewModel.isRecording ? viewModel.recordingDuration : 0))
                    .font(.system(size: 54, weight: .thin, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 16)

            // Waveform (Real-time live animation from recording amplitude)
            HStack(spacing: 4) {
                ForEach(0..<viewModel.recordingLevels.count, id: \.self) { index in
                    let level = CGFloat(viewModel.recordingLevels[index])
                    let height = max(8, level * 72)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: viewModel.isRecording ? [.red, .orange] : [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: height)
                }
            }
            .frame(height: 80)
            .animation(.linear(duration: 0.05), value: viewModel.recordingLevels)

            // Record Button Area
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    viewModel.toggleRecording()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.isRecording ? Color.red.opacity(0.15) : AppColors.primaryGradientStart.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .scaleEffect(viewModel.isRecording ? 1.2 : 1.0)
                        .animation(viewModel.isRecording ? .easeInOut(duration: 1.0).repeatForever(autoreverses: true) : .default, value: viewModel.isRecording)

                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: viewModel.isRecording ? [.red, .orange] : [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 76, height: 76)
                        .shadow(color: viewModel.isRecording ? .red.opacity(0.5) : AppColors.primaryGradientStart.opacity(0.5), radius: 10, x: 0, y: 5)
                    
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
            .padding(.bottom, 12)

            // Recent Recordings Title & List (Displays top 3)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Recent Recordings")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if !viewModel.recordings.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedTab = .recordings
                            }
                        }) {
                            Text("See All")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPurple)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)

                if viewModel.recordings.isEmpty {
                    Spacer()
                    emptyRecordingsView
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(viewModel.recordings.prefix(3)) { recording in
                                RecordingRow(
                                    recording: recording,
                                    isPlaying: viewModel.playingRecordingID == recording.id,
                                    onPlayToggle: {
                                        viewModel.togglePlayback(for: recording)
                                    },
                                    onRename: {
                                        recordingToRename = recording
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showRenameSheet = true
                                        }
                                    },
                                    onDelete: {
                                        withAnimation {
                                            viewModel.deleteRecording(recording)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    // Tab View 2: Scrollable list containing all recordings
    private var recordingsTabContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Recordings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            if viewModel.recordings.isEmpty {
                Spacer()
                emptyRecordingsView
                Spacer()
            } else {
                List {
                    ForEach(viewModel.recordings) { recording in
                        RecordingRow(
                            recording: recording,
                            isPlaying: viewModel.playingRecordingID == recording.id,
                            onPlayToggle: {
                                viewModel.togglePlayback(for: recording)
                            },
                            onRename: {
                                recordingToRename = recording
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showRenameSheet = true
                                }
                            },
                            onDelete: {
                                withAnimation {
                                    viewModel.deleteRecording(recording)
                                }
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

    // Empty recordings state placeholder view
    private var emptyRecordingsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "mic.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            Text(AppStrings.noRecordings)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }

    // Helper: Formatter for active recording clock
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        let hundredths = Int((duration.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, hundredths)
    }
}

// MARK: - Row Element View Card
struct RecordingRow: View {
    let recording: Recording
    let isPlaying: Bool
    let onPlayToggle: () -> Void
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Play / Pause Button
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

            // Info Stack (Title, Date, and Mini visualizer)
            VStack(alignment: .leading, spacing: 6) {
                Text(recording.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(formatDate(recording.createdAt))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                
                // Mini horizontal decorative soundwave representation
                HStack(spacing: 2) {
                    ForEach(0..<24, id: \.self) { i in
                        let height = CGFloat(sin(Double(i) * 0.4) * 6 + 10)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: waveColors),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 2, height: height)
                    }
                }
                .frame(height: 16)
                .padding(.top, 2)
            }
            
            Spacer()

            // Duration & Options Button
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 12) {
                    Text(formatDuration(recording.duration))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(isPlaying ? .orange : (abs(recording.id.hashValue) % 2 == 0 ? AppColors.textPurple : AppColors.borderCyan))
                    
                    // Ellipsis 3-dot popup menu trigger
                    Menu {
                        Button(action: onRename) {
                            Label("Rename", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(6)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
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

    private var waveColors: [Color] {
        if isPlaying {
            return [.orange, .orange.opacity(0.5)]
        } else {
            // Alternate colors based on recording id hash to provide visual variety
            let isEven = abs(recording.id.hashValue) % 2 == 0
            if isEven {
                return [AppColors.primaryGradientStart, AppColors.primaryGradientStart.opacity(0.6)]
            } else {
                return [AppColors.primaryGradientEnd, AppColors.primaryGradientEnd.opacity(0.6)]
            }
        }
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

// MARK: - Preview Showcase
struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView(
            viewModel: RecordingViewModel(
                recorderService: AudioRecorderService(),
                playerService: AudioPlayerService(),
                repository: LocalRecordingRepository()
            )
        )
        .preferredColorScheme(.dark)
    }
}
