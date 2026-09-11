//
//  AddTransactionView.swift
//  FinanceTracker
//

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TransactionViewModel
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
                    
                    // 分类选择器 - 改为可交互
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
                        let transaction = Transaction(
                            amount: amountValue,
                            category: selectedCategory,
                            type: selectedType,
                            date: date,
                            note: note.isEmpty ? selectedCategory.rawValue : note
                        )
                        viewModel.addTransaction(transaction)
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
            .navigationTitle("添加交易").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("取消") { dismiss() } } }
        }
        .sheet(isPresented: $showCategoryPicker) {
            CategoryPickerView(selectedCategory: $selectedCategory)
        }
    }
}

#Preview {
    AddTransactionView().environmentObject(TransactionViewModel())
}
