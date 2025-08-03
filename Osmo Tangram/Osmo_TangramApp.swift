//
//  Osmo_TangramApp.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

@main
struct Osmo_TangramApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("🎮 Osmo Tangram App started")
                }
        }
    }
}
