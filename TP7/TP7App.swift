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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: RecordingItem.self)
    }
}
