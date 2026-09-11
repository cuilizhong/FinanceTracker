//
//  Transaction.swift
//  FinanceTracker
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income = "收入"
    case expense = "支出"
}

struct Transaction: Identifiable, Codable {
    var id = UUID()
    var amount: Double
    var category: Category
    var type: TransactionType
    var date: Date
    var note: String
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "¥0.00"
    }
    
    var displayAmount: String {
        let prefix = type == .income ? "+" : "-"
        return prefix + formattedAmount
    }
}

extension Transaction {
    static let sampleData: [Transaction] = [
        Transaction(amount: 8500, category: .salary, type: .income, date: Date().addingTimeInterval(-86400 * 25), note: "月工资"),
        Transaction(amount: 1200, category: .food, type: .expense, date: Date().addingTimeInterval(-86400 * 20), note: "餐饮消费"),
        Transaction(amount: 3500, category: .shopping, type: .expense, date: Date().addingTimeInterval(-86400 * 18), note: "购买衣物"),
        Transaction(amount: 2000, category: .housing, type: .expense, date: Date().addingTimeInterval(-86400 * 15), note: "房租"),
        Transaction(amount: 500, category: .transportation, type: .expense, date: Date().addingTimeInterval(-86400 * 12), note: "加油"),
        Transaction(amount: 800, category: .entertainment, type: .expense, date: Date().addingTimeInterval(-86400 * 10), note: "电影和聚餐"),
        Transaction(amount: 2000, category: .freelance, type: .income, date: Date().addingTimeInterval(-86400 * 8), note: "兼职收入"),
        Transaction(amount: 1500, category: .food, type: .expense, date: Date().addingTimeInterval(-86400 * 7), note: "超市购物"),
        Transaction(amount: 300, category: .health, type: .expense, date: Date().addingTimeInterval(-86400 * 5), note: "体检"),
        Transaction(amount: 600, category: .education, type: .expense, date: Date().addingTimeInterval(-86400 * 3), note: "在线课程"),
        Transaction(amount: 250, category: .transportation, type: .expense, date: Date().addingTimeInterval(-86400 * 2), note: "打车费用"),
        Transaction(amount: 180, category: .food, type: .expense, date: Date().addingTimeInterval(-86400 * 1), note: "午餐"),
        Transaction(amount: 450, category: .shopping, type: .expense, date: Date(), note: "日用品"),
    ]
}
