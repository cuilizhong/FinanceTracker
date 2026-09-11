//
//  CompoundInterestVM.swift
//  FinanceTracker
//

import Foundation
import Combine

class CompoundInterestVM: ObservableObject {
    @Published var principal: String = "10000"
    @Published var annualRate: String = "5"
    @Published var years: String = "30"
    
    @Published var calculation: CompoundInterestCalculation?
    @Published var errorMessage: String?
    @Published var history: [CompoundInterestCalculation] = []
    
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
        
        guard let y = Int(years), y > 0 else {
            errorMessage = "年数必须大于 0"
            return
        }
        
        var calc = CompoundInterestCalculation(
            principal: p,
            annualRate: rate,
            years: y,
            frequencyResults: [],
            yearlyData: [],
            simpleInterestAmount: 0,
            bestCompoundAmount: 0,
            advantageOverSimple: 0,
            timestamp: Date()
        )
        
        calc.calculate()
        self.calculation = calc
    }
    
    func clearInputs() {
        principal = ""
        annualRate = ""
        years = ""
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
    
    func deleteFromHistory(_ item: CompoundInterestCalculation) {
        history.removeAll { $0.timestamp == item.timestamp }
        saveHistory()
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "CompoundInterestCalculationHistory"),
           let decoded = try? JSONDecoder().decode([CompoundInterestCalculation].self, from: data) {
            history = decoded
        }
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "CompoundInterestCalculationHistory")
        }
    }
}
