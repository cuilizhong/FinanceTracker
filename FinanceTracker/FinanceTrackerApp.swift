//
//  FinanceTrackerApp.swift
//  FinanceTracker
//

import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var viewModel = TransactionViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
