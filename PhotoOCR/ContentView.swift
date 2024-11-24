//
//  ContentView.swift
//  PhotoOCR
//
//  Created by Con Coucoumakis on 24/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            
            SavedPhotosView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.stack.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            
            ReceiptScannerView()
                .tabItem {
                    Label("Receipts", systemImage: "receipt.fill")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
            
            OCRHistoryView()
                .tabItem {
                    Label("OCR History", systemImage: "text.viewfinder")
                }
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
