//
//  CompoundInterestCalculation.swift
//  FinanceTracker
//

import Foundation

enum CompoundFrequency: String, CaseIterable, Codable {
    case annual = "年复利"
    case semiAnnual = "半年复利"
    case quarterly = "季度复利"
    case monthly = "月复利"
    case daily = "日复利"
    case continuous = "连续复利"
    
    var frequency: Int {
        switch self {
        case .annual: return 1
        case .semiAnnual: return 2
        case .quarterly: return 4
        case .monthly: return 12
        case .daily: return 365
        case .continuous: return 0  // 特殊标记
        }
    }
}

struct CompoundFrequencyResult: Identifiable, Codable {
    var id = UUID()
    var frequency: String
    var finalAmount: Double
    var profit: Double
    var growthMultiple: Double  // 增长倍数
    
    var profitPercentage: Double {
        return (profit / (finalAmount - profit)) * 100
    }
}

struct CompoundYearlyData: Identifiable, Codable {
    var id = UUID()
    var year: Int
    var simpleInterestAmount: Double
    var yearlyCompoundAmount: Double
    var monthlyCompoundAmount: Double
    var advantageOverSimple: Double
}

struct CompoundInterestCalculation: Codable {
    // 输入参数
    var principal: Double          // 本金
    var annualRate: Double         // 年利率 (%)
    var years: Int                 // 投资年数
    
    // 输出
    var frequencyResults: [CompoundFrequencyResult]
    var yearlyData: [CompoundYearlyData]
    var simpleInterestAmount: Double       // 单利总额
    var bestCompoundAmount: Double         // 最优复利总额（连续复利）
    var advantageOverSimple: Double        // 相比单利的优势
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case principal, annualRate, years, frequencyResults, yearlyData
        case simpleInterestAmount, bestCompoundAmount, advantageOverSimple, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(principal, forKey: .principal)
        try container.encode(annualRate, forKey: .annualRate)
        try container.encode(years, forKey: .years)
        try container.encode(frequencyResults, forKey: .frequencyResults)
        try container.encode(yearlyData, forKey: .yearlyData)
        try container.encode(simpleInterestAmount, forKey: .simpleInterestAmount)
        try container.encode(bestCompoundAmount, forKey: .bestCompoundAmount)
        try container.encode(advantageOverSimple, forKey: .advantageOverSimple)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        principal = try container.decode(Double.self, forKey: .principal)
        annualRate = try container.decode(Double.self, forKey: .annualRate)
        years = try container.decode(Int.self, forKey: .years)
        frequencyResults = try container.decode([CompoundFrequencyResult].self, forKey: .frequencyResults)
        yearlyData = try container.decode([CompoundYearlyData].self, forKey: .yearlyData)
        simpleInterestAmount = try container.decode(Double.self, forKey: .simpleInterestAmount)
        bestCompoundAmount = try container.decode(Double.self, forKey: .bestCompoundAmount)
        advantageOverSimple = try container.decode(Double.self, forKey: .advantageOverSimple)
        let timeInterval = try container.decode(TimeInterval.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: timeInterval)
    }
    
    init(principal: Double, annualRate: Double, years: Int, frequencyResults: [CompoundFrequencyResult], yearlyData: [CompoundYearlyData], simpleInterestAmount: Double, bestCompoundAmount: Double, advantageOverSimple: Double, timestamp: Date) {
        self.principal = principal
        self.annualRate = annualRate
        self.years = years
        self.frequencyResults = frequencyResults
        self.yearlyData = yearlyData
        self.simpleInterestAmount = simpleInterestAmount
        self.bestCompoundAmount = bestCompoundAmount
        self.advantageOverSimple = advantageOverSimple
        self.timestamp = timestamp
    }
    
    mutating func calculate() {
        let annualRateDecimal = annualRate / 100
        frequencyResults = []
        yearlyData = []
        
        // 计算单利
        simpleInterestAmount = principal + (principal * annualRateDecimal * Double(years))
        
        // 计算不同频率的复利
        for frequency in CompoundFrequency.allCases {
            let finalAmount: Double
            
            if frequency == .continuous {
                // 连续复利：A = Pe^(rt)
                finalAmount = principal * exp(annualRateDecimal * Double(years))
            } else {
                // 标准复利：A = P(1 + r/n)^(nt)
                let n = Double(frequency.frequency)
                let rate = annualRateDecimal / n
                let periods = n * Double(years)
                finalAmount = principal * pow(1 + rate, periods)
            }
            
            let profit = finalAmount - principal
            let growthMultiple = finalAmount / principal
            
            frequencyResults.append(CompoundFrequencyResult(
                frequency: frequency.rawValue,
                finalAmount: finalAmount,
                profit: profit,
                growthMultiple: growthMultiple
            ))
        }
        
        // 设置最优复利（连续复利）
        if let best = frequencyResults.last {
            bestCompoundAmount = best.finalAmount
            advantageOverSimple = best.finalAmount - simpleInterestAmount
        }
        
        // 生成年度数据
        generateYearlyData(annualRateDecimal: annualRateDecimal)
    }
    
    mutating func generateYearlyData(annualRateDecimal: Double) {
        yearlyData = []
        
        for year in 1...years {
            let yearDouble = Double(year)
            
            // 单利
            let simpleAmount = principal + (principal * annualRateDecimal * yearDouble)
            
            // 年复利
            let yearlyCompound = principal * pow(1 + annualRateDecimal, yearDouble)
            
            // 月复利
            let monthRate = annualRateDecimal / 12
            let monthlyCompound = principal * pow(1 + monthRate, yearDouble * 12)
            
            // 优势
            let advantage = monthlyCompound - simpleAmount
            
            yearlyData.append(CompoundYearlyData(
                year: year,
                simpleInterestAmount: simpleAmount,
                yearlyCompoundAmount: yearlyCompound,
                monthlyCompoundAmount: monthlyCompound,
                advantageOverSimple: advantage
            ))
        }
    }
}
