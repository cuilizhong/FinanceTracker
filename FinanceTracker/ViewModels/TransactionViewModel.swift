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
    
    enum TimePeriod: String, CaseIterable {
        case week = "周"
        case month = "月"
        case year = "年"
    }
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        transactions = Transaction.sampleData.sorted { $0.date > $1.date }
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.insert(transaction, at: 0)
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
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
