//
//  FinanceTrackerApp.swift
//  FinanceTracker
//

import SwiftUI

@main
struct FinanceTrackerApp: App {
    @StateObject private var viewModel = TransactionViewModel()
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    init() {
        // 强制重新加载样本数据（用于更新样本数据）
        StorageManager.shared.forceReloadSampleData()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
