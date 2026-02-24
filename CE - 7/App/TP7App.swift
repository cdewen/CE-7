//
//  TP7App.swift
//  TP7
//
//  Created by Carter Ewen on 2/19/26.
//

import SwiftUI
import SwiftData

@main
struct TP7App: App {
    @AppStorage("hasSeenTutorial") private var hasSeenTutorial = false
    @State private var showTutorial = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $showTutorial) {
                    TutorialView(isPresented: $showTutorial)
                }
                .onAppear {
                    if !hasSeenTutorial {
                        showTutorial = true
                    }
                }
                .onChange(of: showTutorial) { _, newValue in
                    if !newValue {
                        hasSeenTutorial = true
                    }
                }
        }
        .modelContainer(for: RecordingItem.self)
    }
}
