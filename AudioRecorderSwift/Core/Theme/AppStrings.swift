import Foundation

public struct AppStrings {
    // App Title & Splash
    public static let appTitlePrefix = "AudioRecord"
    public static let appTitleSuffix = "Swift"
    public static let loadingText = "Loading recordings..."

    // Buttons
    public static let allowAccess = "Allow Access"
    public static let cancel = "Cancel"
    public static let save = "Save"
    
    // Permission Card & Screen
    public static let micPermissionTitle = "Microphone Access Needed"
    public static let micPermissionDesc = "AudioRecordSwift needs access to your microphone to record and save audio."
    public static let circularButtonCaption = "Use for small UI spaces"
    
    // Permission Dialog (Splash/Alert popup)
    public static let allowMicTitlePrefix = "Allow "
    public static let allowMicTitleMiddle = "Microphone"
    public static let allowMicTitleSuffix = "\nAccess"
    public static let micDeniedTitle = "Microphone Access Denied"
    public static let micDeniedDesc = "Microphone access is required to record audio. Please enable it in your system settings to continue."
    public static let openSettings = "Open Settings"
    public static let notNow = "Not Now"
    
    // Header Info
    public static let headerDefault = "AUDIO RECORDER"
    public static let headerRecording = "RECORDING"
    public static let headerSavedRecordings = "SAVED RECORDINGS"
    public static let noRecordings = "No recordings yet"
    
    // Dialog Actions
    public static let renameTitle = "Rename Recording"
    public static let renameMessage = "Enter a new name for this recording."
}
