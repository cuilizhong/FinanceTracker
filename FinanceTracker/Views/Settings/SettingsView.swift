//
//  SettingsView.swift
//  FinanceTracker
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("设置").font(.title).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                
                // 外观设置
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "palette.fill").foregroundColor(.indigo).frame(width: 28)
                        Text("外观").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: "moon.fill").foregroundColor(.indigo).frame(width: 24)
                            Text("深色模式").font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                }
                
                // 数据管理
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "database.fill").foregroundColor(.blue).frame(width: 28)
                        Text("数据管理").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Button {
                        viewModel.loadSampleData()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise").foregroundColor(.blue).frame(width: 24)
                            Text("重新加载演示数据").font(.subheadline).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                    
                    Button {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill").foregroundColor(.red).frame(width: 24)
                            Text("清空所有数据").font(.subheadline).foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                }
                
                // 关于
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill").foregroundColor(.orange).frame(width: 28)
                        Text("关于").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("版本").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text("1.0.0").font(.subheadline).fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                    
                    HStack {
                        Text("技术栈").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text("SwiftUI").font(.subheadline).fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .alert("清空数据", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("清空", role: .destructive) {
                viewModel.transactions.removeAll()
            }
        } message: {
            Text("确定要清空所有交易数据吗？此操作无法撤销。")
        }
    }
}

#Preview {
    SettingsView().environmentObject(TransactionViewModel())
}
