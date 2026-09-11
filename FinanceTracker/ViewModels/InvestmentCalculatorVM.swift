//
//  InvestmentCalculatorVM.swift
//  FinanceTracker
//

import Foundation
import Combine

class InvestmentCalculatorVM: ObservableObject {
    // 一次性投资参数
    @Published var oneTimeAmount: String = "100000"
    @Published var oneTimeRate: String = "8"
    @Published var oneTimeYears: String = "5"
    
    // 定期投资参数
    @Published var regularAmount: String = "5000"
    @Published var regularRate: String = "8"
    @Published var regularMonths: String = "60"
    @Published var regularStartDate = Date()
    
    // 模式选择
    @Published var selectedMode: InvestmentMode = .oneTime
    
    // 计算结果
    @Published var calculation: InvestmentCalculation?
    @Published var errorMessage: String?
    
    // 历史记录
    @Published var history: [InvestmentCalculation] = []
    
    init() {
        loadHistory()
        calculate()
    }
    
    func calculate() {
        errorMessage = nil
        
        guard let rate = Double(oneTimeRate), rate >= 0, rate <= 100 else {
            errorMessage = "年利率必须在 0-100% 之间"
            return
        }
        
        var calc = InvestmentCalculation(
            annualRate: rate,
            initialAmount: Double(oneTimeAmount) ?? 0,
            years: Int(oneTimeYears) ?? 0,
            monthlyAmount: Double(regularAmount) ?? 0,
            months: Int(regularMonths) ?? 0,
            startDate: regularStartDate,
            mode: selectedMode,
            totalInvested: 0,
            finalAmount: 0,
            totalProfit: 0,
            monthlyData: [],
            timestamp: Date()
        )
        
        // 验证输入
        if selectedMode == .oneTime {
            guard let amount = Double(oneTimeAmount), amount > 0 else {
                errorMessage = "初始投资额必须大于 0"
                return
            }
            guard let years = Int(oneTimeYears), years > 0 else {
                errorMessage = "投资年限必须大于 0"
                return
            }
            calc.initialAmount = amount
            calc.years = years
            calc.calculateOneTime()
        } else {
            guard let amount = Double(regularAmount), amount > 0 else {
                errorMessage = "月投资额必须大于 0"
                return
            }
            guard let months = Int(regularMonths), months > 0 else {
                errorMessage = "投资月数必须大于 0"
                return
            }
            calc.monthlyAmount = amount
            calc.months = months
            calc.calculateRegular()
        }
        
        self.calculation = calc
    }
    
    func clearInputs() {
        if selectedMode == .oneTime {
            oneTimeAmount = ""
            oneTimeRate = ""
            oneTimeYears = ""
        } else {
            regularAmount = ""
            regularRate = ""
            regularMonths = ""
        }
        calculation = nil
        errorMessage = nil
    }
    
    func saveToHistory() {
        guard var calc = calculation else { return }
        calc.timestamp = Date()
        history.insert(calc, at: 0)
        if history.count > 50 {
            history.removeLast()
        }
        saveHistory()
    }
    
    func deleteFromHistory(_ item: InvestmentCalculation) {
        history.removeAll { $0.timestamp == item.timestamp }
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "InvestmentCalculationHistory"),
           let decoded = try? JSONDecoder().decode([InvestmentCalculation].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "InvestmentCalculationHistory")
        }
    }
    
    func switchMode() {
        selectedMode = selectedMode == .oneTime ? .regular : .oneTime
        calculate()
    }
}
