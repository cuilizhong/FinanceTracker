//
//  AnalyticsView.swift
//  FinanceTracker
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("时间段", selection: $viewModel.selectedPeriod) {
                    ForEach(TransactionViewModel.TimePeriod.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.down.circle.fill").foregroundColor(.green)
                            Text("总收入").font(.caption).foregroundColor(.secondary)
                        }
                        Text("¥\(Int(viewModel.totalIncome))").font(.title3).fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.circle.fill").foregroundColor(.red)
                            Text("总支出").font(.caption).foregroundColor(.secondary)
                        }
                        Text("¥\(Int(viewModel.totalExpense))").font(.title3).fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("分类明细").font(.headline)
                    if viewModel.expensesByCategory().isEmpty {
                        Text("暂无数据").font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.expensesByCategory().enumerated()), id: \.offset) { _, item in
                                HStack {
                                    Circle().fill(item.0.color.opacity(0.2)).frame(width: 40, height: 40)
                                        .overlay { Image(systemName: item.0.icon).foregroundColor(item.0.color).font(.system(size: 18)) }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.0.rawValue).font(.subheadline).fontWeight(.medium)
                                    }
                                    Spacer()
                                    Text("¥\(Int(item.1))").font(.subheadline).fontWeight(.semibold)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
    }
}

#Preview {
    AnalyticsView().environmentObject(TransactionViewModel())
}
