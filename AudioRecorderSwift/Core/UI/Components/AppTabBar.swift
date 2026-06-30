import SwiftUI

/// Tab items representing the view switcher sections
public enum AppTab: Hashable {
    case record
    case recordings
}

/// A premium custom bottom navigation bar that allows switching between Record and Recordings.
public struct AppTabBar: View {
    @Binding public var selectedTab: AppTab
    
    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
            
            HStack {
                // Record Tab Item
                Button(action: {
                    if selectedTab != .record {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = .record
                        }
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: selectedTab == .record ? "mic.fill" : "mic")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                selectedTab == .record ?
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray, Color.gray]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: selectedTab == .record ? AppColors.primaryGradientStart.opacity(0.4) : Color.clear, radius: 4)
                        
                        Text("Record")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedTab == .record ? AppColors.textPrimary : Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                
                // Recordings Tab Item
                Button(action: {
                    if selectedTab != .recordings {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedTab = .recordings
                        }
                    }
                }) {
                    VStack(spacing: 5) {
                        Image(systemName: selectedTab == .recordings ? "folder.fill" : "folder")
                            .font(.system(size: 22))
                            .foregroundStyle(
                                selectedTab == .recordings ?
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                ) : LinearGradient(
                                    gradient: Gradient(colors: [Color.gray, Color.gray]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: selectedTab == .recordings ? AppColors.primaryGradientStart.opacity(0.4) : Color.clear, radius: 4)
                        
                        Text("Recordings")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedTab == .recordings ? AppColors.textPrimary : Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
            .padding(.bottom, safeAreaBottomHeight + 4)
            .background(
                Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.95)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }
    
    // Safely retrieve the bottom safe area padding
    private var safeAreaBottomHeight: CGFloat {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        #endif
        return 8
    }
}

// MARK: - Preview Showcase
struct AppTabBar_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack {
                Spacer()
                AppTabBar(selectedTab: .constant(.record))
            }
        }
        .preferredColorScheme(.dark)
    }
}
