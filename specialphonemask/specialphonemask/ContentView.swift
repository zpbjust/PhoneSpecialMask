//
//  ContentView.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
    var body: some View {
        if hasSeenWelcome {
            HomeView()
        } else {
            WelcomeView()
                .onDisappear {
                    hasSeenWelcome = true
                }
        }
    }
}

#Preview {
    ContentView()
}
