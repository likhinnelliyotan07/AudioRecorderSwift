//
//  AudioRecorderSwiftApp.swift
//  AudioRecorderSwift
//
//  Created by Likhin Nelliyotan on 25/06/26.
//

import SwiftUI

@main
struct AudioRecorderSwiftApp: App {
    
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RecordingView(
                viewModel: RecordingViewModel(
                    recorderService: container.audioRecorderService,
                    playerService: container.audioPlayerService,
                    repository: container.recordingRepository
                )
            )
        }
    }
}
