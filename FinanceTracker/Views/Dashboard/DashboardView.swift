//
//  DashboardView.swift
//  FinanceTracker
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var selectedTransaction: Transaction?
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("你好！").font(.title2).fontWeight(.semibold)
                        Text("今日余额: ¥\(Int(viewModel.balance))").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                    Circle().fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 50, height: 50)
                        .overlay { Image(systemName: "person.fill").foregroundColor(.white).font(.title3) }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // 余额卡片
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
                
                // 快速统计卡片
                HStack(spacing: 12) {
                    QuickStatCard(
                        icon: "calendar",
                        title: "今月交易",
                        value: "\(viewModel.filterTransactions().count)",
                        color: .blue
                    )
                    
                    QuickStatCard(
                        icon: "chart.pie.fill",
                        title: "分类数",
                        value: "\(viewModel.expensesByCategory().count)",
                        color: .orange
                    )
                    
                    QuickStatCard(
                        icon: "arrow.up.right",
                        title: "平均消费",
                        value: "¥\(Int(calculateAverageDailyExpense()))",
                        color: .red
                    )
                }
                .padding(.horizontal)
                
                // 最近交易
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("最近交易").font(.headline)
                        Spacer()
                        Text("全部 (\(viewModel.transactions.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.recentTransactions.isEmpty {
                        Text("暂无交易").font(.subheadline).foregroundColor(.secondary).frame(maxWidth: .infinity, alignment: .center).padding()
                    } else {
                        ForEach(viewModel.recentTransactions) { transaction in
                            TransactionRowView(
                                transaction: transaction,
                                onEdit: {
                                    selectedTransaction = transaction
                                },
                                onDelete: {
                                    transactionToDelete = transaction
                                    showDeleteAlert = true
                                }
                            )
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            EditTransactionView(transaction: transaction)
                .environmentObject(viewModel)
        }
        .alert("删除交易", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                if let transaction = transactionToDelete {
                    viewModel.deleteTransaction(transaction)
                }
            }
        } message: {
            Text("确定要删除这笔交易吗？此操作无法撤销。")
        }
    }
    
    private func calculateAverageDailyExpense() -> Double {
        let filtered = viewModel.filterTransactions()
        let expenses = filtered.filter { $0.type == .expense }
        
        if expenses.isEmpty { return 0 }
        
        let dates = Set(expenses.map { Calendar.current.startOfDay(for: $0.date) })
        let daySpan = max(1, dates.count)
        
        return expenses.map { $0.amount }.reduce(0, +) / Double(daySpan)
    }
}

struct EditTransactionView: View {
    @State var transaction: Transaction
    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var amount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var selectedType: TransactionType = .expense
    @State private var date = Date()
    @State private var note: String = ""
    @State private var showCategoryPicker = false
    
    init(transaction: Transaction) {
        _transaction = State(initialValue: transaction)
        // 在 init 中初始化所有状态，避免首次打开为空白
        _amount = State(initialValue: String(transaction.amount))
        _selectedCategory = State(initialValue: transaction.category)
        _selectedType = State(initialValue: transaction.type)
        _date = State(initialValue: transaction.date)
        _note = State(initialValue: transaction.note)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Picker("类型", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }.pickerStyle(.segmented).padding(.horizontal).padding(.top)
                    
                    VStack(spacing: 8) {
                        Text("金额").font(.subheadline).foregroundColor(.secondary)
                        HStack {
                            Text("¥").font(.system(size: 36, weight: .semibold)).foregroundColor(.secondary)
                            TextField("0", text: $amount)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal)
                    }.padding(.vertical, 20)
                    
                    Button { showCategoryPicker = true } label: {
                        HStack {
                            Circle().fill(selectedCategory.color.opacity(0.2)).frame(width: 40, height: 40)
                                .overlay { Image(systemName: selectedCategory.icon).foregroundColor(selectedCategory.color) }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("分类").font(.caption).foregroundColor(.secondary)
                                Text(selectedCategory.rawValue).foregroundColor(.primary).fontWeight(.medium)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    }
                    .padding(.horizontal)
                    
                    DatePicker("日期", selection: $date, displayedComponents: [.date])
                        .padding().background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("备注").foregroundColor(.primary)
                        TextField("添加备注...", text: $note, axis: .vertical)
                            .lineLimit(3...5).padding(12)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
                    }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6))).padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    Button {
                        guard let amountValue = Double(amount) else { return }
                        var updatedTransaction = transaction
                        updatedTransaction.amount = amountValue
                        updatedTransaction.category = selectedCategory
                        updatedTransaction.type = selectedType
                        updatedTransaction.date = date
                        updatedTransaction.note = note.isEmpty ? selectedCategory.rawValue : note
                        viewModel.updateTransaction(updatedTransaction)
                        dismiss()
                    } label: {
                        Text("保存").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding()
                            .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(15)
                    }
                    .disabled(amount.isEmpty || Double(amount) == nil).opacity(amount.isEmpty || Double(amount) == nil ? 0.5 : 1)
                    .padding(.horizontal).padding(.bottom, 20)
                }
            }
            .navigationTitle("编辑交易").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } } }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
    }
}

#Preview {
    DashboardView().environmentObject(TransactionViewModel())
}

// MARK: - 辅助组件

struct TransactionRowView: View {
    let transaction: Transaction
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var showMenu = false
    
    var body: some View {
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
            
            Menu {
                Button { onEdit() } label: {
                    Label("编辑", systemImage: "pencil")
                }
                Button(role: .destructive) { onDelete() } label: {
                    Label("删除", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal).padding(.vertical, 12)
        .background(Color(.systemGray6)).cornerRadius(12)
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                
                Spacer()
            }
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }
}
