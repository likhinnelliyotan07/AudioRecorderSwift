import SwiftUI

public struct WarningDialog: View {
    let title: String
    let subtitle: String
    let confirmTitle: String
    let cancelTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    public init(
        title: String,
        subtitle: String,
        confirmTitle: String = "Delete",
        cancelTitle: String = "Cancel",
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    public var body: some View {
        ZStack {
            // Dimmed background overlay
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }
            
            // Glassmorphic warning card
            VStack(spacing: 20) {
                // Alert Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 38))
                    .foregroundColor(.red)
                    .padding(.top, 10)
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .lineSpacing(3)
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Cancel Button
                    Button(action: onCancel) {
                        Text(cancelTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    // Confirm/Delete Button
                    Button(action: onConfirm) {
                        Text(confirmTitle)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: Color.red.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
            }
            .padding(.all, 24)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.6), radius: 25, x: 0, y: 12)
        }
    }
}

// MARK: - Preview
struct WarningDialog_Previews: PreviewProvider {
    static var previews: some View {
        WarningDialog(
            title: "Discard Recording?",
            subtitle: "This will permanently delete the current recording.",
            confirmTitle: "Discard",
            onConfirm: {},
            onCancel: {}
        )
        .preferredColorScheme(.dark)
    }
}
