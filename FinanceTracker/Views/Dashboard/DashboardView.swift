//
//  DashboardView.swift
//  FinanceTracker
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var selectedTransaction: Transaction?
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var transactionToDelete: Transaction?
    
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
                            TransactionRowView(
                                transaction: transaction,
                                onEdit: {
                                    selectedTransaction = transaction
                                    showEditSheet = true
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
        .sheet(isPresented: $showEditSheet) {
            if let transaction = selectedTransaction {
                EditTransactionView(transaction: transaction, isPresented: $showEditSheet)
                    .environmentObject(viewModel)
            }
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
}

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
                    .frame(width: 30)
            }
        }
        .padding(.horizontal).padding(.vertical, 12)
        .background(Color(.systemGray6)).cornerRadius(12)
    }
}

struct EditTransactionView: View {
    @State var transaction: Transaction
    @EnvironmentObject var viewModel: TransactionViewModel
    @Binding var isPresented: Bool
    
    @State private var amount: String = ""
    @State private var selectedCategory: Category = .food
    @State private var selectedType: TransactionType = .expense
    @State private var date = Date()
    @State private var note: String = ""
    @State private var showCategoryPicker = false
    
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
                        isPresented = false
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
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { isPresented = false } } }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
        .onAppear {
            amount = String(transaction.amount)
            selectedCategory = transaction.category
            selectedType = transaction.type
            date = transaction.date
            note = transaction.note
        }
    }
}

#Preview {
    DashboardView().environmentObject(TransactionViewModel())
}
