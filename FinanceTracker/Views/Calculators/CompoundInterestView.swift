//
//  CompoundInterestView.swift
//  FinanceTracker
//

import SwiftUI

struct CompoundInterestView: View {
    @StateObject private var viewModel = CompoundInterestVM()
    @State private var showHistory = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 输入区域
                    VStack(spacing: 0) {
                        CalculatorInputField(label: "本金", value: $viewModel.principal, placeholder: "输入金额", suffix: "元")
                            .onChange(of: viewModel.principal) { _ in
                                viewModel.calculate()
                            }
                        
                        Divider().padding(.vertical, 8)
                        
                        CalculatorInputField(label: "年利率", value: $viewModel.annualRate, placeholder: "输入利率", suffix: "%")
                            .onChange(of: viewModel.annualRate) { _ in
                                viewModel.calculate()
                            }
                        
                        Divider().padding(.vertical, 8)
                        
                        CalculatorInputField(label: "投资年数", value: $viewModel.years, placeholder: "输入年数", suffix: "年", keyboardType: .numberPad)
                            .onChange(of: viewModel.years) { _ in
                                viewModel.calculate()
                            }
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal, 16)
                    
                    // 错误提示
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)))
                            .padding(.horizontal, 16)
                    }
                    
                    // 主要结果
                    if let calc = viewModel.calculation {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ResultCard(
                                    title: "期末本息和",
                                    value: CurrencyFormatter.formatCurrency(calc.bestCompoundAmount),
                                    subtitle: "连续复利",
                                    color: .blue
                                )
                                
                                ResultCard(
                                    title: "增长倍数",
                                    value: CurrencyFormatter.formatMultiple(calc.bestCompoundAmount / calc.principal),
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 12) {
                                ResultCard(
                                    title: "利息收益",
                                    value: CurrencyFormatter.formatCurrency(calc.bestCompoundAmount - calc.principal),
                                    color: .orange
                                )
                                
                                ResultCard(
                                    title: "vs 单利",
                                    value: CurrencyFormatter.formatCurrency(calc.advantageOverSimple),
                                    subtitle: "多赚",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 复利频率对比
                        VStack(alignment: .leading, spacing: 12) {
                            Text("复利频率对比")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            VStack(spacing: 8) {
                                // 单利基准
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("单利")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text(CurrencyFormatter.formatCurrency(calc.simpleInterestAmount))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(CurrencyFormatter.formatCurrency(calc.simpleInterestAmount))
                                        .font(.body.weight(.semibold))
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                
                                Divider()
                                
                                // 各复利频率
                                ForEach(calc.frequencyResults) { result in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(result.frequency)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Text(CurrencyFormatter.formatMultiple(result.growthMultiple))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(CurrencyFormatter.formatCurrency(result.finalAmount))
                                                .font(.body.weight(.semibold))
                                                .foregroundColor(.green)
                                            
                                            if result.finalAmount > calc.simpleInterestAmount {
                                                Text("+" + CurrencyFormatter.formatCurrency(result.finalAmount - calc.simpleInterestAmount))
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    .padding(12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        // 年度明细
                        if !calc.yearlyData.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("年度明细")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text("年").frame(width: 40, alignment: .center)
                                            Text("单利").frame(width: 80, alignment: .trailing)
                                            Text("年复利").frame(width: 80, alignment: .trailing)
                                            Text("月复利").frame(width: 80, alignment: .trailing)
                                            Text("优势").frame(width: 100, alignment: .trailing)
                                        }
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.gray)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        
                                        Divider()
                                        
                                        ForEach(calc.yearlyData) { data in
                                            HStack(spacing: 0) {
                                                Text("\(data.year)").frame(width: 40, alignment: .center)
                                                Text(CurrencyFormatter.formatCurrency(data.simpleInterestAmount)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.yearlyCompoundAmount)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.monthlyCompoundAmount)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.advantageOverSimple)).frame(width: 100, alignment: .trailing)
                                            }
                                            .font(.caption2)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            
                                            Divider()
                                        }
                                    }
                                }
                                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white))
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        // 操作按钮
                        HStack(spacing: 12) {
                            Button(action: { viewModel.saveToHistory() }) {
                                Label("保存", systemImage: "bookmark")
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { showHistory = true }) {
                                Label("历史", systemImage: "clock")
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("📈 复利计算器")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHistory) {
                CalculationHistoryView(history: viewModel.history)
            }
        }
    }
}

#Preview {
    CompoundInterestView()
}
