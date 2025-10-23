//
//  specialphonemaskApp.swift
//  specialphonemask
//
//  Created by Nash Zhou on 2025/10/22.
//

import SwiftUI

@main
struct specialphonemaskApp: App {
    
    init() {
        // Initialize RevenueCat
        RCPurchaseManager.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)  // 整个App强制使用亮色模式
        }
    }
}
