//
//  SavingsCalculatorVM.swift
//  FinanceTracker
//

import Foundation
import Combine

class SavingsCalculatorVM: ObservableObject {
    @Published var principal: String = "100000"
    @Published var annualRate: String = "3.85"
    @Published var months: String = "24"
    @Published var interestMethod: InterestMethod = .simple
    @Published var includeTax: Bool = false
    @Published var taxRate: String = "20"
    
    @Published var calculation: SavingsCalculation?
    @Published var errorMessage: String?
    @Published var history: [SavingsCalculation] = []
    
    init() {
        loadHistory()
        calculate()
    }
    
    func calculate() {
        errorMessage = nil
        
        guard let p = Double(principal), p > 0 else {
            errorMessage = "本金必须大于 0"
            return
        }
        
        guard let rate = Double(annualRate), rate >= 0, rate <= 100 else {
            errorMessage = "年利率必须在 0-100% 之间"
            return
        }
        
        guard let m = Int(months), m > 0 else {
            errorMessage = "期限必须大于 0 个月"
            return
        }
        
        guard let tax = Double(taxRate), tax >= 0, tax <= 100 else {
            errorMessage = "税率必须在 0-100% 之间"
            return
        }
        
        var calc = SavingsCalculation(
            principal: p,
            annualRate: rate,
            months: m,
            interestMethod: interestMethod,
            includeTax: includeTax,
            taxRate: tax,
            interestAmount: 0,
            taxAmount: 0,
            afterTaxInterest: 0,
            totalAmount: 0,
            effectiveRate: 0,
            periodComparisons: [],
            timestamp: Date()
        )
        
        calc.calculate()
        self.calculation = calc
    }
    
    func clearInputs() {
        principal = ""
        annualRate = ""
        months = ""
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
    
    func deleteFromHistory(_ item: SavingsCalculation) {
        history.removeAll { $0.timestamp == item.timestamp }
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "SavingsCalculationHistory"),
           let decoded = try? JSONDecoder().decode([SavingsCalculation].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "SavingsCalculationHistory")
        }
    }
}
