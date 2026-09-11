//
//  CurrencyFormatter.swift
//  FinanceTracker
//

import Foundation

struct CurrencyFormatter {
    static func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "¥"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "¥0"
    }
    
    static func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
    
    static func formatPercent(_ value: Double) -> String {
        return String(format: "%.2f%%", value)
    }
    
    static func formatMultiple(_ value: Double) -> String {
        return String(format: "%.2f倍", value)
    }
}
