import SwiftUI

/// Supported button styles based on design specifications
public enum AppButtonStyle {
    case primaryFilled
    case primarySoftGlow
    case secondaryOutline
    case iconCircular
}

/// A highly reusable and modular button component that adheres to the app's premium theme.
public struct AppButton: View {
    public let title: String?
    public let iconName: String?
    public let style: AppButtonStyle
    public let isLoading: Bool
    public let action: () -> Void
    
    @Environment(\.isEnabled) private var isEnabled
    
    public init(
        title: String? = nil,
        iconName: String? = nil,
        style: AppButtonStyle = .primaryFilled,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if !isLoading && isEnabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: spinnerColor))
                        .scaleEffect(1.0)
                }
                
                if let icon = iconName, !isLoading {
                    Image(systemName: icon)
                        .font(.system(size: style == .iconCircular ? 22 : 18, weight: .medium))
                }
                
                if let text = title, style != .iconCircular {
                    Text(text)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: style == .iconCircular ? nil : .infinity)
        }
        .buttonStyle(AppButtonStyles(style: style, isLoading: isLoading))
        .disabled(isLoading || !isEnabled)
    }
    
    private var spinnerColor: Color {
        switch style {
        case .primaryFilled:
            return .white
        case .primarySoftGlow, .secondaryOutline, .iconCircular:
            return AppColors.textPurple
        }
    }
}

/// Native SwiftUI button style configurations for various visual layouts
public struct AppButtonStyles: ButtonStyle {
    public let style: AppButtonStyle
    public let isLoading: Bool
    
    @Environment(\.isEnabled) private var isEnabled
    
    public init(style: AppButtonStyle, isLoading: Bool = false) {
        self.style = style
        self.isLoading = isLoading
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        switch style {
        case .primaryFilled:
            return AnyView(
                configuration.label
                    .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textDisabled)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if !isEnabled {
                                AppColors.buttonDisabled
                            } else if isPressed {
                                AppColors.buttonPressed
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .shadow(color: isEnabled && !isPressed ? AppColors.primaryGradientStart.opacity(0.4) : Color.clear, radius: 10, x: 0, y: 5)
            )
            
        case .primarySoftGlow:
            return AnyView(
                configuration.label
                    .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textDisabled)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if !isEnabled {
                                Color.clear
                            } else {
                                AppColors.primaryGradientStart.opacity(0.08)
                            }
                        }
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                isEnabled ? 
                                    (isPressed ? AppColors.buttonPressed : AppColors.primaryGradientStart.opacity(0.8)) 
                                    : AppColors.buttonDisabled,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: isEnabled && !isPressed ? AppColors.primaryGradientStart.opacity(0.5) : Color.clear, radius: 8, x: 0, y: 0)
            )
            
        case .secondaryOutline:
            return AnyView(
                configuration.label
                    .foregroundColor(isEnabled ? AppColors.textPurple : AppColors.textDisabled)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Color.clear)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                isEnabled ? 
                                    (isPressed ? AppColors.buttonPressed.opacity(0.6) : AppColors.primaryGradientStart.opacity(0.4)) 
                                    : AppColors.buttonDisabled,
                                lineWidth: 1.5
                            )
                    )
            )
            
        case .iconCircular:
            return AnyView(
                configuration.label
                    .foregroundColor(isEnabled ? AppColors.textPrimary : AppColors.textDisabled)
                    .frame(width: 56, height: 56)
                    .background(
                        Group {
                            if !isEnabled {
                                AppColors.buttonDisabled
                            } else {
                                Color.black.opacity(0.3)
                            }
                        }
                    )
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(
                                isEnabled ? 
                                    (isPressed ? AppColors.buttonPressed : AppColors.primaryGradientStart) 
                                    : AppColors.buttonDisabled,
                                lineWidth: 2
                            )
                    )
                    .shadow(color: isEnabled && !isPressed ? AppColors.primaryGradientStart.opacity(0.4) : Color.clear, radius: 6, x: 0, y: 0)
            )
        }
    }
}

public extension ButtonStyle where Self == AppButtonStyles {
    static func appStyle(_ style: AppButtonStyle, isLoading: Bool = false) -> AppButtonStyles {
        AppButtonStyles(style: style, isLoading: isLoading)
    }
}


