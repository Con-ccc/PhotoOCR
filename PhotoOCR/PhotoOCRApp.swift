//
//  PhotoOCRApp.swift
//  PhotoOCR
//
//  Created by Con Coucoumakis on 24/11/2024.
//

import SwiftUI
import SwiftData

@main
struct PhotoOCRApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: TextRecognitionResult.self, ReceiptData.self)
        } catch {
            fatalError("Failed to initialize SwiftData container")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
