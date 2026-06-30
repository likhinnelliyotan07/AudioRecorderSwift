
import Foundation
import Combine

final class AppContainer: ObservableObject {

    lazy var recordingRepository: RecordingRepositoryProtocol =
        LocalRecordingRepository()

    lazy var audioRecorderService: AudioRecorderServiceProtocol =
        AudioRecorderService()

    lazy var audioPlayerService: AudioPlayerServiceProtocol =
        AudioPlayerService()
}
