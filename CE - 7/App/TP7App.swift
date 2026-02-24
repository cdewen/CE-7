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
    @State private var showTutorial: Bool

    init() {
        _showTutorial = State(initialValue: !UserDefaults.standard.bool(forKey: "hasSeenTutorial"))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()

                if showTutorial {
                    TutorialView(isPresented: $showTutorial)
                        .ignoresSafeArea()
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
