import SwiftUI

public struct AppColors {
    // Primary Button Gradient
    public static let primaryGradientStart = Color(red: 0.63, green: 0.28, blue: 0.94) // Violet
    public static let primaryGradientEnd = Color(red: 0.18, green: 0.40, blue: 0.96) // Blue
    
    // Backgrounds
    public static let backgroundDark = Color(red: 0.03, green: 0.03, blue: 0.05)
    public static let backgroundCard = Color(red: 0.08, green: 0.08, blue: 0.12)
    
    // Button States
    public static let buttonPressed = Color(red: 0.24, green: 0.09, blue: 0.54)
    public static let buttonDisabled = Color(red: 0.16, green: 0.17, blue: 0.24)
    public static let textDisabled = Color(red: 0.45, green: 0.47, blue: 0.56)
    
    // Accents & Shadows
    public static let borderCyan = Color(red: 0.20, green: 0.60, blue: 1.00)
    public static let textPurple = Color(red: 0.70, green: 0.40, blue: 1.00) // Vibrant purple for outlined text
    public static let glowColor = Color(red: 0.63, green: 0.28, blue: 0.94).opacity(0.5)
    
    // General
    public static let textPrimary = Color.white
    public static let textSecondary = Color.gray
}
