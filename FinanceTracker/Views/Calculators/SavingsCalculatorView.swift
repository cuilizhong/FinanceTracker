//
//  SavingsCalculatorView.swift
//  FinanceTracker
//

import SwiftUI

struct SavingsCalculatorView: View {
    @StateObject private var viewModel = SavingsCalculatorVM()
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
                        
                        CalculatorInputField(label: "期限", value: $viewModel.months, placeholder: "输入月数", suffix: "月", keyboardType: .numberPad)
                            .onChange(of: viewModel.months) { _ in
                                viewModel.calculate()
                            }
                    }
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal, 16)
                    
                    // 选项设置
                    VStack(spacing: 12) {
                        HStack {
                            Text("计息方式")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Picker("计息方式", selection: $viewModel.interestMethod) {
                                Text("单利").tag(InterestMethod.simple)
                                Text("复利").tag(InterestMethod.compound)
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: viewModel.interestMethod) { _ in
                                viewModel.calculate()
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Toggle("计算税金（20%利息税）", isOn: $viewModel.includeTax)
                            .padding(.horizontal, 16)
                            .onChange(of: viewModel.includeTax) { _ in
                                viewModel.calculate()
                            }
                    }
                    
                    // 错误提示
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.red.opacity(0.1)))
                            .padding(.horizontal, 16)
                    }
                    
                    // 结果展示
                    if let calc = viewModel.calculation {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ResultCard(
                                    title: "到期本息和",
                                    value: CurrencyFormatter.formatCurrency(calc.totalAmount),
                                    color: .blue
                                )
                                
                                ResultCard(
                                    title: "利息收益",
                                    value: CurrencyFormatter.formatCurrency(calc.interestAmount),
                                    color: .green
                                )
                            }
                            
                            if calc.includeTax {
                                HStack(spacing: 12) {
                                    ResultCard(
                                        title: "税后利息",
                                        value: CurrencyFormatter.formatCurrency(calc.afterTaxInterest),
                                        subtitle: "已扣税 \(CurrencyFormatter.formatCurrency(calc.taxAmount))",
                                        color: .orange
                                    )
                                    
                                    ResultCard(
                                        title: "实际收益率",
                                        value: String(format: "%.2f%%", calc.effectiveRate),
                                        color: .purple
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 多期限对比
                        if !calc.periodComparisons.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("期限对比")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text("期限").frame(width: 50, alignment: .center)
                                            Text("利息").frame(width: 80, alignment: .trailing)
                                            Text("本息和").frame(width: 80, alignment: .trailing)
                                            if calc.includeTax {
                                                Text("税后").frame(width: 80, alignment: .trailing)
                                            }
                                            Text("收益率").frame(width: 80, alignment: .trailing)
                                        }
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.gray)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        
                                        Divider()
                                        
                                        ForEach(calc.periodComparisons) { item in
                                            HStack(spacing: 0) {
                                                Text(item.period).frame(width: 50, alignment: .center)
                                                Text(CurrencyFormatter.formatCurrency(item.interestAmount)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(item.totalAmount)).frame(width: 80, alignment: .trailing)
                                                if calc.includeTax {
                                                    Text(CurrencyFormatter.formatCurrency(item.afterTaxInterest)).frame(width: 80, alignment: .trailing)
                                                }
                                                Text(String(format: "%.2f%%", item.effectiveRate)).frame(width: 80, alignment: .trailing)
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
            .navigationTitle("🏦 存款计算器")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHistory) {
                CalculationHistoryView(history: viewModel.history)
            }
        }
    }
}

#Preview {
    SavingsCalculatorView()
}
