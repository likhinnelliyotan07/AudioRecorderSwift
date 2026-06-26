import SwiftUI

/// A custom, premium bottom sheet component to handle renaming a recording.
/// Faithfully reproduces mockup specifications (purple border input, character count, primary/secondary buttons).
public struct RenameBottomSheet: View {
    public let currentName: String
    public let onSave: (String) -> Void
    public let onCancel: () -> Void
    
    @State private var nameText: String = ""
    private let maxCharacters = 80
    
    public init(currentName: String, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.currentName = currentName
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Drag indicator handle
            HStack {
                Spacer()
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 38, height: 5)
                Spacer()
            }
            .padding(.top, 8)
            
            // Header: Title + Close circular button
            HStack {
                Text(AppStrings.renameTitle)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // Descriptive subtitle
            Text(AppStrings.renameMessage)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.top, -8)
            
            // Input Fields Stack
            VStack(alignment: .leading, spacing: 8) {
                // Purple input label
                Text("Recording Name")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textPurple)
                
                // Text Field with custom border and clear button
                HStack(spacing: 8) {
                    TextField("", text: $nameText)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .onChange(of: nameText) { newValue in
                            if newValue.count > maxCharacters {
                                nameText = String(newValue.prefix(maxCharacters))
                            }
                        }
                    
                    if !nameText.isEmpty {
                        Button(action: { nameText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.all, 14)
                .background(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryGradientStart, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Character counter
                Text("\(nameText.count)/\(maxCharacters)")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.top, 4)
            
            // Primary & Secondary Buttons
            VStack(spacing: 12) {
                // Primary Rename (Gradient)
                AppButton(
                    title: "Rename",
                    style: .primaryFilled
                ) {
                    onSave(nameText)
                }
                .disabled(nameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                // Secondary Cancel (Outline)
                AppButton(
                    title: "Cancel",
                    style: .secondaryOutline
                ) {
                    onCancel()
                }
            }
            .padding(.bottom, safeAreaBottomHeight + 12)
        }
        .padding(.horizontal, 24)
        .background(
            Color(red: 0.08, green: 0.08, blue: 0.12).opacity(0.85)
        )
        .background(.ultraThinMaterial)
        .clipShape(RenameCustomCorner(corners: [.topLeft, .topRight], radius: 24))
        .overlay(
            RenameCustomCorner(corners: [.topLeft, .topRight], radius: 24)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            nameText = currentName
        }
    }
    
    private var safeAreaBottomHeight: CGFloat {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        #endif
        return 16
    }
}

// Custom shape to round only top left and top right corners of the bottom sheet
struct RenameCustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview Showcase
struct RenameBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            AppColors.backgroundDark.ignoresSafeArea()
            
            VStack {
                Spacer()
                RenameBottomSheet(
                    currentName: "Interview with Alex",
                    onSave: { _ in },
                    onCancel: {}
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .preferredColorScheme(.dark)
    }
}
