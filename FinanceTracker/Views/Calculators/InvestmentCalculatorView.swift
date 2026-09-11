//
//  InvestmentCalculatorView.swift
//  FinanceTracker
//

import SwiftUI

struct InvestmentCalculatorView: View {
    @StateObject private var viewModel = InvestmentCalculatorVM()
    @State private var showHistory = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 模式切换
                    Picker("投资模式", selection: $viewModel.selectedMode) {
                        Text("一次性投资").tag(InvestmentMode.oneTime)
                        Text("定期投资").tag(InvestmentMode.regular)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .onChange(of: viewModel.selectedMode) { _ in
                        viewModel.calculate()
                    }
                    
                    // 输入区域
                    VStack(spacing: 0) {
                        if viewModel.selectedMode == .oneTime {
                            CalculatorInputField(label: "初始投资额", value: $viewModel.oneTimeAmount, placeholder: "输入金额", suffix: "元")
                                .onChange(of: viewModel.oneTimeAmount) { _ in
                                    viewModel.calculate()
                                }
                            
                            Divider().padding(.vertical, 8)
                            
                            CalculatorInputField(label: "年收益率", value: $viewModel.oneTimeRate, placeholder: "输入利率", suffix: "%")
                                .onChange(of: viewModel.oneTimeRate) { _ in
                                    viewModel.calculate()
                                }
                            
                            Divider().padding(.vertical, 8)
                            
                            CalculatorInputField(label: "投资年限", value: $viewModel.oneTimeYears, placeholder: "输入年数", suffix: "年", keyboardType: .numberPad)
                                .onChange(of: viewModel.oneTimeYears) { _ in
                                    viewModel.calculate()
                                }
                        } else {
                            CalculatorInputField(label: "月投资额", value: $viewModel.regularAmount, placeholder: "输入金额", suffix: "元")
                                .onChange(of: viewModel.regularAmount) { _ in
                                    viewModel.calculate()
                                }
                            
                            Divider().padding(.vertical, 8)
                            
                            CalculatorInputField(label: "年收益率", value: $viewModel.regularRate, placeholder: "输入利率", suffix: "%")
                                .onChange(of: viewModel.regularRate) { _ in
                                    viewModel.calculate()
                                }
                            
                            Divider().padding(.vertical, 8)
                            
                            CalculatorInputField(label: "投资月数", value: $viewModel.regularMonths, placeholder: "输入月数", suffix: "月", keyboardType: .numberPad)
                                .onChange(of: viewModel.regularMonths) { _ in
                                    viewModel.calculate()
                                }
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
                    
                    // 结果展示
                    if let calc = viewModel.calculation {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                ResultCard(
                                    title: "期末总额",
                                    value: CurrencyFormatter.formatCurrency(calc.finalAmount),
                                    color: .blue
                                )
                                
                                ResultCard(
                                    title: "投资收益",
                                    value: CurrencyFormatter.formatCurrency(calc.totalProfit),
                                    color: .green
                                )
                            }
                            
                            HStack(spacing: 12) {
                                ResultCard(
                                    title: "总投入",
                                    value: CurrencyFormatter.formatCurrency(calc.totalInvested),
                                    color: .gray
                                )
                                
                                ResultCard(
                                    title: "收益率",
                                    value: String(format: "%.2f%%", (calc.totalProfit / calc.totalInvested) * 100),
                                    color: .orange
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // 明细表格
                        if !calc.monthlyData.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("投资明细")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        // 表头
                                        HStack(spacing: 0) {
                                            Text("期数").frame(width: 50, alignment: .center)
                                            Text("投入").frame(width: 80, alignment: .trailing)
                                            Text("累计").frame(width: 80, alignment: .trailing)
                                            Text("收益").frame(width: 80, alignment: .trailing)
                                            Text("余额").frame(width: 100, alignment: .trailing)
                                        }
                                        .font(.caption2.weight(.semibold))
                                        .foregroundColor(.gray)
                                        .padding(8)
                                        .background(Color(.systemGray5))
                                        
                                        Divider()
                                        
                                        // 数据行
                                        ForEach(calc.monthlyData.prefix(12)) { data in
                                            HStack(spacing: 0) {
                                                Text("\(data.month)").frame(width: 50, alignment: .center)
                                                Text(CurrencyFormatter.formatCurrency(data.monthlyAmount)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.totalInvested)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.profit)).frame(width: 80, alignment: .trailing)
                                                Text(CurrencyFormatter.formatCurrency(data.totalAmount)).frame(width: 100, alignment: .trailing)
                                            }
                                            .font(.caption2)
                                            .padding(8)
                                            .background(Color(.systemGray6))
                                            
                                            Divider()
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
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
            .navigationTitle("💰 投资计算器")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showHistory) {
                CalculationHistoryView(history: viewModel.history)
            }
        }
    }
}

#Preview {
    InvestmentCalculatorView()
}
