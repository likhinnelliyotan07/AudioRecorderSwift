import SwiftUI

/// A custom, premium permission request dialog conforming to visual specs.
/// Supports both the initial permission request state and the denied state redirection.
public struct MicPermissionDialog: View {
    public let isDenied: Bool
    public let onAction: () -> Void   // Action for 'Allow Access' or 'Open Settings'
    public let onDismiss: () -> Void  // Action for closing (X) or 'Not Now'
    
    // Waveform line heights for decorative vector art (simulating the mockup)
    private let leftWaveHeights: [CGFloat] = [6, 12, 18, 28, 16, 24, 38, 20, 12, 8]
    private let rightWaveHeights: [CGFloat] = [8, 12, 20, 38, 24, 16, 28, 18, 12, 6]
    
    public init(isDenied: Bool, onAction: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.isDenied = isDenied
        self.onAction = onAction
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            // Semi-transparent overlay behind dialog to dim main content
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Dialog Panel
            VStack(spacing: 28) {
                // Top header controls
                HStack {
                    Spacer()
                    // Close 'X' Button
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(10)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, -8)
                
                // Vector Graphic: Glowing Mic + Horizontal Waveforms
                HStack(spacing: 16) {
                    // Left Waveform lines
                    HStack(spacing: 3) {
                        ForEach(0..<leftWaveHeights.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primaryGradientStart.opacity(0.5), AppColors.primaryGradientEnd.opacity(0.15)]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 3, height: leftWaveHeights[index])
                        }
                    }
                    
                    // Central glowing microphone ring
                    ZStack {
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart.opacity(0.6), AppColors.primaryGradientEnd.opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 104, height: 104)
                            .shadow(color: AppColors.primaryGradientStart.opacity(0.4), radius: 8)
                        
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 90, height: 90)
                        
                        Image(systemName: "mic.fill")
                            .font(.system(size: 38))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: AppColors.primaryGradientStart.opacity(0.45), radius: 6)
                    }
                    
                    // Right Waveform lines
                    HStack(spacing: 3) {
                        ForEach(0..<rightWaveHeights.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primaryGradientStart.opacity(0.5), AppColors.primaryGradientEnd.opacity(0.15)]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(width: 3, height: rightWaveHeights[index])
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                // Dialog Descriptive Content
                VStack(spacing: 12) {
                    if isDenied {
                        // Title for Denied Permission State
                        Text(AppStrings.micDeniedTitle)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                    } else {
                        // Title with Purple highlight on "Microphone"
                        Group {
                            Text(AppStrings.allowMicTitlePrefix)
                                .foregroundColor(AppColors.textPrimary) +
                            Text(AppStrings.allowMicTitleMiddle)
                                .foregroundColor(AppColors.textPurple) +
                            Text(AppStrings.allowMicTitleSuffix)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    }
                    
                    Text(isDenied ? AppStrings.micDeniedDesc : AppStrings.micPermissionDesc)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 12)
                }
                
                // Action Buttons
                VStack(spacing: 16) {
                    // Primary Action Button (Gradient filled)
                    AppButton(
                        title: isDenied ? AppStrings.openSettings : AppStrings.allowAccess,
                        iconName: isDenied ? "gear" : "mic.fill",
                        style: .primaryFilled,
                        action: onAction
                    )
                    
                    // Not Now (Dismiss action)
                    Button(action: onDismiss) {
                        Text(AppStrings.notNow)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.textPurple.opacity(0.85))
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.all, 24)
            .frame(width: 330)
            .background(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.75))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.6), radius: 24, x: 0, y: 10)
        }
    }
}

// MARK: - Preview
struct MicPermissionDialog_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            MicPermissionDialog(
                isDenied: false,
                onAction: {},
                onDismiss: {}
            )
        }
        .preferredColorScheme(.dark)
    }
}
