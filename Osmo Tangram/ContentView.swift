//
//  ContentView.swift
//  Osmo Tangram
//
//  Created by Roosh on 8/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainMenuView()
            .onAppear {
                print("🚀 App launched - showing main menu")
            }
    }
}

#Preview {
    ContentView()
}
