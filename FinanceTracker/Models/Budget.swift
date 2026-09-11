//
//  Budget.swift
//  FinanceTracker
//

import Foundation

struct Budget: Identifiable, Codable {
    var id = UUID()
    var category: Category
    var monthlyLimit: Double
    var createdDate: Date
    var isActive: Bool = true
    
    /// 当月已支出金额
    var currentMonthExpense: Double = 0
    
    /// 预算进度百分比
    var progressPercentage: Double {
        guard monthlyLimit > 0 else { return 0 }
        return min((currentMonthExpense / monthlyLimit) * 100, 100)
    }
    
    /// 是否超出预算
    var isOverBudget: Bool {
        currentMonthExpense > monthlyLimit
    }
    
    /// 剩余预算
    var remainingBudget: Double {
        max(monthlyLimit - currentMonthExpense, 0)
    }
    
    /// 超出金额
    var overspentAmount: Double {
        max(currentMonthExpense - monthlyLimit, 0)
    }
}
