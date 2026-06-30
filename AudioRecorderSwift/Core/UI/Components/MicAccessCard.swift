import SwiftUI

/// A custom card component used to request microphone permissions from the user,
/// matching the 'Layout in Context' visual specifications.
public struct MicAccessCard: View {
    public let onAllowAccess: () -> Void
    
    public init(onAllowAccess: @escaping () -> Void) {
        self.onAllowAccess = onAllowAccess
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Icon layout representing the glowing visualizer
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.35))
                    .frame(width: 48, height: 48)
                
                // Outer subtle wave circles
                Circle()
                    .stroke(AppColors.primaryGradientStart.opacity(0.25), lineWidth: 1)
                    .frame(width: 58, height: 58)
                
                Circle()
                    .stroke(AppColors.primaryGradientEnd.opacity(0.12), lineWidth: 1)
                    .frame(width: 68, height: 68)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .padding(.trailing, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(AppStrings.micPermissionTitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(AppStrings.micPermissionDesc)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            // Primary Allow Access button on the right
            AppButton(
                title: AppStrings.allowAccess,
                iconName: "mic.fill",
                style: .primaryFilled,
                action: onAllowAccess
            )
            .frame(width: 154)
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview Showcase
struct MicAccessCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack {
                Text("LAYOUT IN CONTEXT")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 12)
                
                MicAccessCard(onAllowAccess: {
                    print("Requesting microphone permissions...")
                })
                .padding(.horizontal)
            }
        }
        .preferredColorScheme(.dark)
    }
}
