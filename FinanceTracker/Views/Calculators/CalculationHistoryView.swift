//
//  CalculationHistoryView.swift
//  FinanceTracker
//

import SwiftUI

struct CalculationHistoryView: View {
    let historyItems: [String]  // 用字符串表示历史项
    @Environment(\.dismiss) var dismiss
    
    init(history: [Any]) {
        self.historyItems = history.enumerated().map { index, _ in
            "计算结果 #\(index + 1)"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if historyItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.badge.xmark")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("暂无历史记录")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("您的计算结果将保存在这里")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    List {
                        ForEach(historyItems.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("计算结果")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text(historyItems[index])
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("¥100,000")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    
                                    Text(Date().formatted(date: .numeric, time: .shortened))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalculationHistoryView(history: [])
}
