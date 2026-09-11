//
//  SavingsCalculation.swift
//  FinanceTracker
//

import Foundation

enum InterestMethod: Codable {
    case simple         // 单利
    case compound       // 复利
}

struct SavingsPeriodComparison: Identifiable, Codable {
    var id = UUID()
    var period: String         // "1年", "2年" 等
    var months: Int
    var principalAmount: Double
    var interestAmount: Double
    var taxAmount: Double
    var afterTaxInterest: Double
    var totalAmount: Double
    var effectiveRate: Double
}

struct SavingsCalculation: Codable {
    // 输入参数
    var principal: Double          // 本金
    var annualRate: Double         // 年利率 (%)
    var months: Int                // 存款期限（月）
    var interestMethod: InterestMethod  // 计息方法
    var includeTax: Bool           // 是否计算税金
    var taxRate: Double            // 税率 (默认20%)
    
    // 输出
    var interestAmount: Double     // 利息
    var taxAmount: Double          // 税金
    var afterTaxInterest: Double   // 税后利息
    var totalAmount: Double        // 本息和
    var effectiveRate: Double      // 实际收益率 (%)
    var periodComparisons: [SavingsPeriodComparison]
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case principal, annualRate, months, interestMethod, includeTax, taxRate
        case interestAmount, taxAmount, afterTaxInterest, totalAmount, effectiveRate
        case periodComparisons, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(principal, forKey: .principal)
        try container.encode(annualRate, forKey: .annualRate)
        try container.encode(months, forKey: .months)
        try container.encode(interestMethod, forKey: .interestMethod)
        try container.encode(includeTax, forKey: .includeTax)
        try container.encode(taxRate, forKey: .taxRate)
        try container.encode(interestAmount, forKey: .interestAmount)
        try container.encode(taxAmount, forKey: .taxAmount)
        try container.encode(afterTaxInterest, forKey: .afterTaxInterest)
        try container.encode(totalAmount, forKey: .totalAmount)
        try container.encode(effectiveRate, forKey: .effectiveRate)
        try container.encode(periodComparisons, forKey: .periodComparisons)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        principal = try container.decode(Double.self, forKey: .principal)
        annualRate = try container.decode(Double.self, forKey: .annualRate)
        months = try container.decode(Int.self, forKey: .months)
        interestMethod = try container.decode(InterestMethod.self, forKey: .interestMethod)
        includeTax = try container.decode(Bool.self, forKey: .includeTax)
        taxRate = try container.decode(Double.self, forKey: .taxRate)
        interestAmount = try container.decode(Double.self, forKey: .interestAmount)
        taxAmount = try container.decode(Double.self, forKey: .taxAmount)
        afterTaxInterest = try container.decode(Double.self, forKey: .afterTaxInterest)
        totalAmount = try container.decode(Double.self, forKey: .totalAmount)
        effectiveRate = try container.decode(Double.self, forKey: .effectiveRate)
        periodComparisons = try container.decode([SavingsPeriodComparison].self, forKey: .periodComparisons)
        let timeInterval = try container.decode(TimeInterval.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: timeInterval)
    }
    
    init(principal: Double, annualRate: Double, months: Int, interestMethod: InterestMethod, includeTax: Bool, taxRate: Double, interestAmount: Double, taxAmount: Double, afterTaxInterest: Double, totalAmount: Double, effectiveRate: Double, periodComparisons: [SavingsPeriodComparison], timestamp: Date) {
        self.principal = principal
        self.annualRate = annualRate
        self.months = months
        self.interestMethod = interestMethod
        self.includeTax = includeTax
        self.taxRate = taxRate
        self.interestAmount = interestAmount
        self.taxAmount = taxAmount
        self.afterTaxInterest = afterTaxInterest
        self.totalAmount = totalAmount
        self.effectiveRate = effectiveRate
        self.periodComparisons = periodComparisons
        self.timestamp = timestamp
    }
    
    mutating func calculate() {
        let annualRateDecimal = annualRate / 100
        let monthRate = annualRateDecimal / 12
        let periods = Double(months)
        
        // 计算利息
        if interestMethod == .simple {
            // 单利：利息 = 本金 × 年利率 × 年数
            interestAmount = principal * annualRateDecimal * (periods / 12)
        } else {
            // 复利：A = P(1 + r/12)^n，利息 = A - P
            totalAmount = principal * pow(1 + monthRate, periods)
            interestAmount = totalAmount - principal
        }
        
        // 计算税金
        if includeTax {
            taxAmount = interestAmount * taxRate / 100
            afterTaxInterest = interestAmount - taxAmount
        } else {
            taxAmount = 0
            afterTaxInterest = interestAmount
        }
        
        // 计算本息和
        if interestMethod == .simple {
            totalAmount = principal + interestAmount
        }
        
        // 计算实际收益率
        let actualPeriod = periods / 12  // 转换为年
        effectiveRate = (interestAmount / principal / actualPeriod) * 100
        
        // 生成对比表
        generatePeriodComparisons()
    }
    
    mutating func generatePeriodComparisons() {
        periodComparisons = []
        let periods = [1, 2, 3, 5]  // 1年、2年、3年、5年
        let annualRateDecimal = annualRate / 100
        let monthRate = annualRateDecimal / 12
        
        for year in periods {
            let monthsForPeriod = year * 12
            let periodMonthRate = monthRate
            
            var periodInterest: Double
            var periodTotal: Double
            
            if interestMethod == .simple {
                periodInterest = principal * annualRateDecimal * Double(year)
                periodTotal = principal + periodInterest
            } else {
                periodTotal = principal * pow(1 + periodMonthRate, Double(monthsForPeriod))
                periodInterest = periodTotal - principal
            }
            
            let periodTax = includeTax ? periodInterest * taxRate / 100 : 0
            let periodAfterTax = periodInterest - periodTax
            let periodRate = (periodInterest / principal / Double(year)) * 100
            
            periodComparisons.append(SavingsPeriodComparison(
                period: "\(year)年",
                months: monthsForPeriod,
                principalAmount: principal,
                interestAmount: periodInterest,
                taxAmount: periodTax,
                afterTaxInterest: periodAfterTax,
                totalAmount: periodTotal,
                effectiveRate: periodRate
            ))
        }
    }
}
