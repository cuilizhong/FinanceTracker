//
//  DashboardView.swift
//  FinanceTracker
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("你好！").font(.title2).fontWeight(.semibold)
                            Text("欢迎使用理财追踪器").font(.subheadline).foregroundColor(.secondary)
                        }
                        Spacer()
                        Circle().fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 50, height: 50)
                            .overlay { Image(systemName: "person.fill").foregroundColor(.white).font(.title3) }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        Text("当前余额").font(.subheadline).foregroundColor(.white.opacity(0.8))
                        Text("¥ \(Int(viewModel.balance))").font(.system(size: 42, weight: .bold, design: .rounded)).foregroundColor(.white)
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text("收入: ¥\(Int(viewModel.totalIncome))").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            }
                            VStack(spacing: 8) {
                                Text("支出: ¥\(Int(viewModel.totalExpense))").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 25).fill(LinearGradient(colors: [.blue, .purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("最近交易").font(.headline).padding(.horizontal)
                        if viewModel.recentTransactions.isEmpty {
                            Text("暂无交易").font(.subheadline).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding()
                        } else {
                            ForEach(viewModel.recentTransactions) { transaction in
                                HStack(spacing: 12) {
                                    Circle().fill(transaction.category.color.opacity(0.2)).frame(width: 50, height: 50)
                                        .overlay { Image(systemName: transaction.category.icon).foregroundColor(transaction.category.color) }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(transaction.category.rawValue).font(.subheadline).fontWeight(.medium)
                                        Text(transaction.note).font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(transaction.displayAmount).font(.subheadline).fontWeight(.semibold)
                                        .foregroundColor(transaction.type == .income ? .green : .primary)
                                }
                                .padding(.horizontal).padding(.vertical, 12)
                                .background(Color(.systemGray6)).cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
            }
        }
    }


#Preview {
    DashboardView().environmentObject(TransactionViewModel())
}
