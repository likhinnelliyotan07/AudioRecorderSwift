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
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashView(repository: container.recordingRepository) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                    }
                }
            } else {
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
}
