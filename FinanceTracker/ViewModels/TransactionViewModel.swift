//
//  TransactionViewModel.swift
//  FinanceTracker
//

import Foundation
import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var selectedPeriod: TimePeriod = .month
    
    private let storageManager = StorageManager.shared
    
    enum TimePeriod: String, CaseIterable {
        case week = "周"
        case month = "月"
        case year = "年"
    }
    
    init() {
        loadData()
    }
    
    /// 初始化加载数据：首次启动加载样本数据，之后加载本地保存的数据
    private func loadData() {
        if storageManager.isFirstLaunch() {
            // 首次启动，加载样本数据
            loadSampleData()
            storageManager.markAsLaunched()
        } else {
            // 后续启动，加载本地保存的数据
            transactions = storageManager.loadTransactions().sorted { $0.date > $1.date }
        }
    }
    
    func loadSampleData() {
        transactions = Transaction.sampleData.sorted { $0.date > $1.date }
        saveTransactions()
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        saveTransactions()
    }
    
    /// 编辑交易
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
            saveTransactions()
        }
    }
    
    /// 保存交易到本地存储
    private func saveTransactions() {
        storageManager.saveTransactions(transactions)
    }
    
    /// 清空所有数据
    func clearAllTransactions() {
        transactions.removeAll()
        storageManager.clearAllData()
    }
    
    /// 重置为样本数据（用于测试）
    func resetToSampleData() {
        loadSampleData()
    }
    
    var totalIncome: Double {
        filterTransactions().filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpense: Double {
        filterTransactions().filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    
    var balance: Double { totalIncome - totalExpense }
    
    var recentTransactions: [Transaction] { Array(transactions.prefix(10)) }
    
    func expensesByCategory() -> [(Category, Double)] {
        let filtered = filterTransactions().filter { $0.type == .expense }
        var categoryTotals: [Category: Double] = [:]
        for transaction in filtered {
            categoryTotals[transaction.category, default: 0] += transaction.amount
        }
        return categoryTotals.sorted { $0.value > $1.value }
    }
    
    func topCategories(limit: Int = 5) -> [(Category, Double)] {
        Array(expensesByCategory().prefix(limit))
    }
    
    func dailyTotals() -> [(Date, Double)] {
        let filtered = filterTransactions()
        var dailyData: [Date: Double] = [:]
        let calendar = Calendar.current
        for transaction in filtered {
            let day = calendar.startOfDay(for: transaction.date)
            let amount = transaction.type == .income ? transaction.amount : -transaction.amount
            dailyData[day, default: 0] += amount
        }
        return dailyData.sorted { $0.key < $1.key }
    }
    
    private func filterTransactions() -> [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        switch selectedPeriod {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
            return transactions.filter { $0.date >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now)!
            return transactions.filter { $0.date >= monthAgo }
        case .year:
            let yearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
            return transactions.filter { $0.date >= yearAgo }
        }
    }
}
