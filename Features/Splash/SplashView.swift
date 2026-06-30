import SwiftUI
import AVFoundation

/// A premium, stylized Splash Screen representing the entry point of the app.
/// Incorporates vector graphics, ambient gradients, background pre-loading,
/// and complete microphone permission checking (handling both approved and denied flows).
public struct SplashView: View {
    let repository: RecordingRepositoryProtocol
    let onFinished: () -> Void
    
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.85
    @State private var loadingProgress: CGFloat = 0.0
    @State private var backgroundOffset: CGFloat = 0.0
    
    // Permission state tracking
    @State private var showPermissionDialog = false
    @State private var isPermissionDenied = false
    @State private var isAuthorized = false
    @State private var hasAppeared = false
    
    public init(repository: RecordingRepositoryProtocol, onFinished: @escaping () -> Void) {
        self.repository = repository
        self.onFinished = onFinished
    }
    
    public var body: some View {
        ZStack {
            // Ambient Velvet Background with Glossy Folds
            AppColors.backgroundDark
                .ignoresSafeArea()
            
            // Purple light beam from top-left
            RadialGradient(
                colors: [AppColors.primaryGradientStart.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            // Blue light beam from bottom-right
            RadialGradient(
                colors: [AppColors.primaryGradientEnd.opacity(0.18), .clear],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 450
            )
            .ignoresSafeArea()
            
            // Abstract wave overlay (simulating glossy fabric)
            VStack {
                Spacer()
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 300))
                    path.addCurve(
                        to: CGPoint(x: 500, y: 200),
                        control1: CGPoint(x: 150, y: 150),
                        control2: CGPoint(x: 350, y: 400)
                    )
                    path.addLine(to: CGPoint(x: 500, y: 500))
                    path.addLine(to: CGPoint(x: 0, y: 500))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.2),
                            Color.black.opacity(0.0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .blur(radius: 50)
                .frame(height: 400)
                .offset(y: 100 + backgroundOffset)
            }
            
            // Main Content Area
            VStack(spacing: 32) {
                Spacer()
                
                // Stylized Microphone and Rings
                SplashMicrophoneGraphic()
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .shadow(color: AppColors.primaryGradientStart.opacity(0.15), radius: 20, y: 10)
                
                // App Brand Name Layout
                HStack(spacing: 0) {
                    Text(AppStrings.appTitlePrefix)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(AppStrings.appTitleSuffix)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppColors.primaryGradientStart.opacity(0.4), radius: 6)
                }
                .opacity(opacity)
                .offset(y: opacity == 1.0 ? 0 : 20)
                
                Spacer()
                
                // Progress Indicator OR Permission Request Block
                VStack(spacing: 16) {
                    if isAuthorized {
                        // Standard Loading State
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 220, height: 4)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 220 * loadingProgress, height: 4)
                                .shadow(color: AppColors.primaryGradientStart.opacity(0.5), radius: 4)
                        }
                        
                        Text(AppStrings.loadingText)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .opacity(0.7)
                    } else {
                        // Keep a clean layout spacing when permission dialog is open or closed
                        Spacer().frame(height: 50)
                    }
                }
                .padding(.bottom, 64)
                .opacity(opacity)
            }
            
            // Custom Permission Modal Popup Overlay
            if showPermissionDialog {
                MicPermissionDialog(
                    isDenied: isPermissionDenied,
                    onAction: {
                        if isPermissionDenied {
                            openSystemSettings()
                        } else {
                            requestSystemPermission()
                        }
                    },
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showPermissionDialog = false
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            
            // Fluid fade-in and pop animations
            withAnimation(.spring(response: 1.0, dampingFraction: 0.75, blendDuration: 0)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Slow motion background wave shift
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                backgroundOffset = -30
            }
            
            // Animate progress loading bar
            withAnimation(.easeInOut(duration: 1.8)) {
                loadingProgress = 1.0
            }
            
            // Background pre-loading execution
            preloadAndCheckPermissions()
        }
    }
    
    // Preloads recordings and runs permission checks
    private func preloadAndCheckPermissions() {
        let startTime = Date()
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Warm up database
            _ = repository.fetchRecordings()
            
            let elapsed = Date().timeIntervalSince(startTime)
            let remainingDelay = max(0.1, 1.8 - elapsed)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + remainingDelay) {
                checkPermissionState()
            }
        }
    }
    
    // Evaluates microphone authorization and updates view states
    private func checkPermissionState() {
        #if os(iOS)
        let permission = AVAudioSession.sharedInstance().recordPermission
        
        switch permission {
        case .granted:
            isAuthorized = true
            onFinished()
        case .denied:
            isAuthorized = false
            isPermissionDenied = true
            withAnimation(.spring()) {
                showPermissionDialog = true
            }
        case .undetermined:
            isAuthorized = false
            isPermissionDenied = false
            withAnimation(.spring()) {
                showPermissionDialog = true
            }
        @unknown default:
            isAuthorized = true
            onFinished()
        }
        #else
        // Auto-approve on non-iOS environments (Simulator/macOS compilation)
        isAuthorized = true
        onFinished()
        #endif
    }
    
    // Requests hardware permission from iOS
    private func requestSystemPermission() {
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    isAuthorized = true
                    withAnimation {
                        showPermissionDialog = false
                    }
                    onFinished()
                } else {
                    isAuthorized = false
                    withAnimation {
                        isPermissionDenied = true
                    }
                }
            }
        }
        #else
        isAuthorized = true
        onFinished()
        #endif
    }
    
    // Redirects user to settings
    private func openSystemSettings() {
        #if os(iOS)
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
        #endif
    }
}

// MARK: - Splash Vector Microphone Graphic
struct SplashMicrophoneGraphic: View {
    var body: some View {
        ZStack {
            // Glowing neon portal ring
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 144, height: 144)
                .shadow(color: AppColors.primaryGradientStart.opacity(0.6), radius: 12)
            
            // Pedestal stage base
            VStack(spacing: 0) {
                Spacer().frame(height: 72)
                
                // Top layer of circular stage
                Ellipse()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.16, green: 0.13, blue: 0.28), Color(red: 0.05, green: 0.05, blue: 0.08)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 154, height: 22)
                    .overlay(
                        Ellipse()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart.opacity(0.4), AppColors.primaryGradientEnd.opacity(0.1)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: AppColors.primaryGradientStart.opacity(0.25), radius: 4, y: 1)
                
                // Pedestal height ring
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(red: 0.09, green: 0.07, blue: 0.14), Color(red: 0.04, green: 0.04, blue: 0.06)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 154, height: 10)
                    .overlay(
                        Rectangle()
                            .stroke(AppColors.primaryGradientStart.opacity(0.08), lineWidth: 1)
                    )
            }
            
            // Stylized vector microphone
            VStack(spacing: 0) {
                // Mic Capsule Head
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.primaryGradientStart, Color(red: 0.38, green: 0.22, blue: 0.76)]),
                                startPoint: .top,
                                endPoint: .bottom
                              )
                        )
                        .frame(width: 48, height: 80)
                        .shadow(color: AppColors.primaryGradientStart.opacity(0.45), radius: 10)
                    
                    // Grille lines details
                    VStack(spacing: 6) {
                        ForEach(0..<4) { _ in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.black.opacity(0.35))
                                .frame(width: 32, height: 3)
                        }
                    }
                    
                    // Center separator bar
                    Rectangle()
                        .fill(Color.black.opacity(0.18))
                        .frame(width: 3, height: 60)
                }
                
                // Mount & Stem connector
                ZStack(alignment: .top) {
                    // Curved support bracket (U-Shape)
                    Path { path in
                        path.addArc(center: CGPoint(x: 35, y: 0), radius: 35, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                    }
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 70, height: 35)
                    
                    // Vertical stand pole
                    Rectangle()
                        .fill(AppColors.primaryGradientEnd)
                        .frame(width: 6, height: 26)
                        .padding(.top, 35)
                }
                .frame(width: 70, height: 61)
                
                // Joint fitting
                Ellipse()
                    .fill(AppColors.primaryGradientEnd)
                    .frame(width: 26, height: 8)
            }
            .offset(y: -18)
        }
        .frame(width: 200, height: 200)
    }
}
