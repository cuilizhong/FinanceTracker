//
//  BarChartView.swift
//  FinanceTracker
//

import SwiftUI

struct BarChartView: View {
    let incomeData: [(String, Double)]
    let expenseData: [(String, Double)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            
            if incomeData.isEmpty && expenseData.isEmpty {
                Text("暂无数据").font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 200)
            } else {
                Canvas { context, size in
                    let allValues = (incomeData.map { $0.1 } + expenseData.map { $0.1 })
                    let maxValue = allValues.max() ?? 1
                    let barCount = max(incomeData.count, expenseData.count)
                    
                    let barWidth = size.width / CGFloat(barCount * 3)
                    let spacing = size.width / CGFloat(barCount) - barWidth * 2
                    
                    for i in 0..<barCount {
                        let x = CGFloat(i) * (barWidth * 2 + spacing) + spacing / 2
                        
                        // 收入柱
                        if i < incomeData.count {
                            let height = (incomeData[i].1 / maxValue) * (size.height * 0.8)
                            let barRect = CGRect(
                                x: x,
                                y: size.height - height - 20,
                                width: barWidth,
                                height: height
                            )
                            context.fill(
                                Path(roundedRect: barRect, cornerRadius: 4),
                                with: .color(.green)
                            )
                        }
                        
                        // 支出柱
                        if i < expenseData.count {
                            let height = (expenseData[i].1 / maxValue) * (size.height * 0.8)
                            let barRect = CGRect(
                                x: x + barWidth + 4,
                                y: size.height - height - 20,
                                width: barWidth,
                                height: height
                            )
                            context.fill(
                                Path(roundedRect: barRect, cornerRadius: 4),
                                with: .color(.red)
                            )
                        }
                    }
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 图例
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2).fill(.green).frame(width: 12, height: 12)
                        Text("收入").font(.caption)
                    }
                    
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 2).fill(.red).frame(width: 12, height: 12)
                        Text("支出").font(.caption)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        let totalIncome = incomeData.map { $0.1 }.reduce(0, +)
                        let totalExpense = expenseData.map { $0.1 }.reduce(0, +)
                        
                        HStack {
                            Text("收入: ¥\(Int(totalIncome))").font(.caption2).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("支出: ¥\(Int(totalExpense))").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)))
    }
}

#Preview {
    let incomeData = [
        ("周1", 5000.0),
        ("周2", 3000.0),
        ("周3", 6000.0),
        ("周4", 4000.0),
    ]
    
    let expenseData = [
        ("周1", 2000.0),
        ("周2", 2500.0),
        ("周3", 1800.0),
        ("周4", 2200.0),
    ]
    
    BarChartView(incomeData: incomeData, expenseData: expenseData, title: "收支对比")
        .padding()
}
