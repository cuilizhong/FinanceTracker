//
//  InvestmentCalculation.swift
//  FinanceTracker
//

import Foundation

enum InvestmentMode: Codable {
    case oneTime        // 一次性投资
    case regular        // 定期投资（定投）
}

struct MonthlyInvestmentData: Identifiable, Codable {
    var id = UUID()
    var month: Int
    var monthlyAmount: Double      // 该月投入金额
    var totalInvested: Double      // 累计投入
    var profit: Double             // 利息收益
    var totalAmount: Double        // 累计金额
}

struct InvestmentCalculation: Codable {
    // 共用参数
    var annualRate: Double         // 年收益率 (%)
    
    // 一次性投资
    var initialAmount: Double      // 初始投资额
    var years: Int                 // 投资年限
    
    // 定期投资
    var monthlyAmount: Double      // 月投资额
    var months: Int                // 投资月数
    var startDate: Date            // 投资开始日期
    
    // 输出
    var mode: InvestmentMode
    var totalInvested: Double      // 总投入
    var finalAmount: Double        // 期末金额
    var totalProfit: Double        // 总收益
    var monthlyData: [MonthlyInvestmentData]
    var timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case annualRate, initialAmount, years, monthlyAmount, months
        case startDate, mode, totalInvested, finalAmount, totalProfit
        case monthlyData, timestamp
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(annualRate, forKey: .annualRate)
        try container.encode(initialAmount, forKey: .initialAmount)
        try container.encode(years, forKey: .years)
        try container.encode(monthlyAmount, forKey: .monthlyAmount)
        try container.encode(months, forKey: .months)
        try container.encode(startDate.timeIntervalSince1970, forKey: .startDate)
        try container.encode(mode, forKey: .mode)
        try container.encode(totalInvested, forKey: .totalInvested)
        try container.encode(finalAmount, forKey: .finalAmount)
        try container.encode(totalProfit, forKey: .totalProfit)
        try container.encode(monthlyData, forKey: .monthlyData)
        try container.encode(timestamp.timeIntervalSince1970, forKey: .timestamp)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        annualRate = try container.decode(Double.self, forKey: .annualRate)
        initialAmount = try container.decode(Double.self, forKey: .initialAmount)
        years = try container.decode(Int.self, forKey: .years)
        monthlyAmount = try container.decode(Double.self, forKey: .monthlyAmount)
        months = try container.decode(Int.self, forKey: .months)
        let startTimeInterval = try container.decode(TimeInterval.self, forKey: .startDate)
        startDate = Date(timeIntervalSince1970: startTimeInterval)
        mode = try container.decode(InvestmentMode.self, forKey: .mode)
        totalInvested = try container.decode(Double.self, forKey: .totalInvested)
        finalAmount = try container.decode(Double.self, forKey: .finalAmount)
        totalProfit = try container.decode(Double.self, forKey: .totalProfit)
        monthlyData = try container.decode([MonthlyInvestmentData].self, forKey: .monthlyData)
        let timeInterval = try container.decode(TimeInterval.self, forKey: .timestamp)
        timestamp = Date(timeIntervalSince1970: timeInterval)
    }
    
    init(annualRate: Double, initialAmount: Double, years: Int, monthlyAmount: Double, months: Int, startDate: Date, mode: InvestmentMode, totalInvested: Double, finalAmount: Double, totalProfit: Double, monthlyData: [MonthlyInvestmentData], timestamp: Date) {
        self.annualRate = annualRate
        self.initialAmount = initialAmount
        self.years = years
        self.monthlyAmount = monthlyAmount
        self.months = months
        self.startDate = startDate
        self.mode = mode
        self.totalInvested = totalInvested
        self.finalAmount = finalAmount
        self.totalProfit = totalProfit
        self.monthlyData = monthlyData
        self.timestamp = timestamp
    }
    
    mutating func calculateOneTime() {
        totalInvested = initialAmount
        let monthRate = annualRate / 100 / 12
        let periods = years * 12
        
        finalAmount = initialAmount * pow(1 + monthRate, Double(periods))
        totalProfit = finalAmount - totalInvested
        monthlyData = []
        
        var currentAmount = initialAmount
        for month in 1...periods {
            currentAmount = initialAmount * pow(1 + monthRate, Double(month))
            let profit = currentAmount - initialAmount
            monthlyData.append(MonthlyInvestmentData(
                month: month,
                monthlyAmount: initialAmount,
                totalInvested: initialAmount,
                profit: profit,
                totalAmount: currentAmount
            ))
        }
    }
    
    mutating func calculateRegular() {
        let monthRate = annualRate / 100 / 12
        totalInvested = monthlyAmount * Double(months)
        
        // 使用等比数列求和公式：S = a*((1+r)^n - 1) / r
        // 其中 a 是月投资额，r 是月利率，n 是月数
        finalAmount = monthlyAmount * ((pow(1 + monthRate, Double(months)) - 1) / monthRate)
        totalProfit = finalAmount - totalInvested
        
        monthlyData = []
        var currentAmount = 0.0
        
        for month in 1...months {
            let monthAmountWithInterest = monthlyAmount * pow(1 + monthRate, Double(months - month + 1))
            currentAmount += monthlyAmount * pow(1 + monthRate, Double(months - month + 1))
            
            let accumulatedProfit = currentAmount - (monthlyAmount * Double(month))
            monthlyData.append(MonthlyInvestmentData(
                month: month,
                monthlyAmount: monthlyAmount,
                totalInvested: monthlyAmount * Double(month),
                profit: accumulatedProfit,
                totalAmount: currentAmount
            ))
        }
        
        // 修正最后一个值
        if !monthlyData.isEmpty {
            monthlyData[monthlyData.count - 1].totalAmount = finalAmount
            monthlyData[monthlyData.count - 1].profit = totalProfit
        }
    }
}
