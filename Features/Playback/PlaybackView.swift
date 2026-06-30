import SwiftUI

/// A full-screen playback panel supporting media seeking, rate adjustments, rewinds, and bookmarks.
public struct PlaybackView: View {
    @ObservedObject var viewModel: RecordingViewModel
    let onBack: () -> Void
    
    @State private var isDraggingWaveform = false
    @State private var dragStartProgress: Double = 0.0
    @State private var wasPlayingBeforeDrag = false
    @State private var showRenameSheet = false
    @State private var showDeleteConfirmation = false
    
    public init(viewModel: RecordingViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }
    
    public var body: some View {
        ZStack {
            // Dark velvet background
            AppColors.backgroundDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Bar (Back, Title, Subtitle, Options)
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                Spacer()
                
                // High-fidelity Playback Waveform
                playbackWaveformView
                    .padding(.horizontal, 24)
                
                // Time Duration Stamps
                HStack {
                    Text(formatTime(viewModel.playbackTime))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppColors.textPurple)
                    
                    Spacer()
                    
                    Text(formatRemainingTime(viewModel.playbackTime))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppColors.borderCyan)
                }
                .padding(.horizontal, 24)
                .padding(.top, -8)
                
                // Interactive Timeline Custom Slider
                timelineSliderView
                    .padding(.horizontal, 24)
                
                Spacer()
                
                // Core Media Controls Row
                mediaControlsRowView
                    .padding(.horizontal, 24)
                
                Spacer()
            }
            
            // Reusable Warning Dialog for Deletion
            if showDeleteConfirmation, let recording = viewModel.selectedRecordingForPlayback {
                WarningDialog(
                    title: "Delete Recording?",
                    subtitle: "This will permanently delete '\(recording.name)'.",
                    confirmTitle: "Delete",
                    onConfirm: {
                        viewModel.deleteRecording(recording)
                        showDeleteConfirmation = false
                        onBack()
                    },
                    onCancel: {
                        showDeleteConfirmation = false
                    }
                )
                .zIndex(5.0)
            }
            
            // Rename Bottom Sheet Overlay (Local to PlaybackView)
            if showRenameSheet {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .zIndex(3.0)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showRenameSheet = false
                        }
                    }
                
                VStack {
                    Spacer()
                    RenameBottomSheet(
                        currentName: viewModel.selectedRecordingForPlayback?.name ?? "",
                        onSave: { newName in
                            if let recording = viewModel.selectedRecordingForPlayback {
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
                .zIndex(4.0)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.loadWaveformForSelectedRecording()
        }
    }
    
    // MARK: - Subviews
    
    // Header Bar view
    private var headerView: some View {
        HStack {
            // Back button
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Title & Subtitle Stack
            VStack(spacing: 4) {
                Text(viewModel.selectedRecordingForPlayback?.name ?? "Recording Details")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                if let date = viewModel.selectedRecordingForPlayback?.createdAt {
                    Text(formatDate(date))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Options Button with Dropdown Menu (Rename/Delete)
            Menu {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showRenameSheet = true
                    }
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    withAnimation {
                        showDeleteConfirmation = true
                    }
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
    
    // High-fidelity Playback Waveform View
    private var playbackWaveformView: some View {
        GeometryReader { geometry in
            let viewportWidth = geometry.size.width
            let centerOffset = viewportWidth / 2
            
            let amplitudes = viewModel.selectedWaveformAmplitudes.isEmpty ? Array(repeating: Float(0.05), count: 80) : viewModel.selectedWaveformAmplitudes
            let barWidth: CGFloat = 4
            let barSpacing: CGFloat = 3
            let totalBarWidth = barWidth + barSpacing
            let totalWaveformWidth = CGFloat(amplitudes.count) * totalBarWidth - barSpacing
            
            let currentPosition = CGFloat(viewModel.playbackProgress) * totalWaveformWidth
            let offsetX = centerOffset - currentPosition
            
            ZStack(alignment: .leading) {
                // Waveform bars representation
                HStack(alignment: .center, spacing: barSpacing) {
                    ForEach(0..<amplitudes.count, id: \.self) { index in
                        let amp = CGFloat(amplitudes[index])
                        let barHeight = max(6, amp * 80)
                        
                        let barPosition = CGFloat(index) * totalBarWidth
                        let isPlayed = barPosition <= currentPosition
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                isPlayed ?
                                LinearGradient(
                                    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientStart.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) :
                                LinearGradient(
                                    colors: [AppColors.borderCyan.opacity(0.8), AppColors.borderCyan.opacity(0.3)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: barWidth, height: barHeight)
                    }
                }
                .frame(width: totalWaveformWidth, height: 100)
                .offset(x: offsetX)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDraggingWaveform {
                                isDraggingWaveform = true
                                wasPlayingBeforeDrag = viewModel.isPlaying
                                dragStartProgress = viewModel.playbackProgress
                                if viewModel.isPlaying {
                                    viewModel.pausePlaybackForSelected()
                                }
                            }
                            let dragDelta = value.translation.width
                            let progressDelta = Double(dragDelta / totalWaveformWidth)
                            let targetProgress = max(0.0, min(1.0, dragStartProgress - progressDelta))
                            let targetTime = targetProgress * viewModel.playbackDuration
                            viewModel.seekPlaybackForSelected(to: targetTime)
                        }
                        .onEnded { _ in
                            isDraggingWaveform = false
                            if wasPlayingBeforeDrag {
                                viewModel.resumePlaybackForSelected()
                            }
                        }
                )
                
                // Static vertical center playhead line with glowing head
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2, height: 100)
                    .overlay(
                        Circle()
                            .fill(AppColors.primaryGradientStart)
                            .frame(width: 8, height: 8)
                            .shadow(color: AppColors.primaryGradientStart.opacity(0.8), radius: 4)
                            .offset(y: -4)
                        , alignment: .top
                    )
                    .offset(x: centerOffset - 1)
            }
            .frame(height: 100)
            .clipped()
        }
        .frame(height: 100)
    }
    
    // Premium custom seek timeline slider
    private var timelineSliderView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 4)
                
                // Active Track
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(viewModel.playbackProgress)), height: 4)
                
                // Slider Thumb
                Circle()
                    .fill(AppColors.primaryGradientStart)
                    .frame(width: 14, height: 14)
                    .shadow(color: AppColors.primaryGradientStart.opacity(0.7), radius: 4)
                    .offset(x: max(0, geometry.size.width * CGFloat(viewModel.playbackProgress) - 7))
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let percent = Double(value.location.x / geometry.size.width)
                                let targetPercent = max(0.0, min(1.0, percent))
                                let time = targetPercent * viewModel.playbackDuration
                                viewModel.seekPlaybackForSelected(to: time)
                            }
                    )
            }
        }
        .frame(height: 16)
    }
    
    // Core Media Controls Row view
    private var mediaControlsRowView: some View {
        HStack(spacing: 0) {
            // Speed Button Control
            Button(action: {
                viewModel.toggleSpeed()
            }) {
                VStack(spacing: 6) {
                    Text(String(format: "%.1fx", viewModel.playbackSpeed))
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 44)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    Text("Speed")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Rewind 10s
            Button(action: {
                viewModel.rewind10Seconds()
            }) {
                Image(systemName: "gobackward.10")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Main Play/Pause Button
            Button(action: {
                viewModel.togglePlaybackForSelected()
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 72, height: 72)
                        .shadow(color: AppColors.primaryGradientStart.opacity(0.4), radius: 8)
                    
                    Circle()
                        .fill(Color.black.opacity(0.35))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: viewModel.isPlaying ? 0 : 2) // alignment offset
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Fast Forward 10s
            Button(action: {
                viewModel.fastForward10Seconds()
            }) {
                Image(systemName: "goforward.10")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Empty balance block aligning speed button
            Spacer()
                .frame(width: 50)
        }
    }
    

    
    // MARK: - Helpers
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatRemainingTime(_ time: TimeInterval) -> String {
        let remaining = max(0, viewModel.playbackDuration - time)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "-%02d:%02d", minutes, seconds)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct PlaybackView_Previews: PreviewProvider {
    static var previews: some View {
        PlaybackView(
            viewModel: RecordingViewModel(
                recorderService: AudioRecorderService(),
                playerService: AudioPlayerService(),
                repository: LocalRecordingRepository()
            ),
            onBack: {}
        )
        .preferredColorScheme(.dark)
    }
}
