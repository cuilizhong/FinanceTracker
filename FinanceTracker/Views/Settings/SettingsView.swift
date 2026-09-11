//
//  SettingsView.swift
//  FinanceTracker
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @State private var showResetAlert = false
    @State private var showExportOptions = false
    @State private var exportMessage = ""
    @State private var showExportSuccess = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("设置").font(.title).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                
                // 外观设置
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "paintbrush.fill").foregroundColor(.indigo).frame(width: 28)
                        Text("外观").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Toggle(isOn: $isDarkMode) {
                        HStack {
                            Image(systemName: "moon.stars.fill").foregroundColor(.indigo).frame(width: 24)
                            Text("深色模式").font(.subheadline)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                }
                
                // 数据导出
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill").foregroundColor(.blue).frame(width: 28)
                        Text("数据导出").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Menu {
                        Button {
                            exportData(format: .csv)
                        } label: {
                            Label("导出为 CSV", systemImage: "doc.text")
                        }
                        
                        Button {
                            exportData(format: .json)
                        } label: {
                            Label("导出为 JSON", systemImage: "doc.circle")
                        }
                        
                        Button {
                            showReport()
                        } label: {
                            Label("生成统计报告", systemImage: "doc.richtext")
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.up.doc").foregroundColor(.blue).frame(width: 24)
                            Text("导出交易数据").font(.subheadline).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
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
                        Image(systemName: "database.fill").foregroundColor(.green).frame(width: 28)
                        Text("数据管理").font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    Button {
                        viewModel.resetToSampleData()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise").foregroundColor(.green).frame(width: 24)
                            Text("重置为演示数据").font(.subheadline).foregroundColor(.primary)
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
                        Text("2.0").font(.subheadline).fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                    
                    HStack {
                        Text("技术栈").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text("SwiftUI + MVVM").font(.subheadline).fontWeight(.medium)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                    .padding(.horizontal)
                    
                    HStack {
                        Text("交易数").font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                        Text("\(viewModel.transactions.count)").font(.subheadline).fontWeight(.medium)
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
                viewModel.clearAllTransactions()
            }
        } message: {
            Text("确定要清空所有交易数据吗？此操作无法撤销。")
        }
        .alert("导出成功", isPresented: $showExportSuccess) {
            Button("确定") { }
        } message: {
            Text(exportMessage)
        }
    }
    
    private func exportData(format: ExportFormat) {
        let manager = ExportManager.shared
        
        switch format {
        case .csv:
            if let url = manager.exportToCSV(viewModel.transactions) {
                exportMessage = "已导出为 CSV 文件:\n\(url.lastPathComponent)\n\n文件已保存到 \"文件\" 应用的文档目录中。"
                showExportSuccess = true
            }
        case .json:
            if let url = manager.exportToJSON(viewModel.transactions) {
                exportMessage = "已导出为 JSON 备份文件:\n\(url.lastPathComponent)\n\n文件已保存到 \"文件\" 应用的文档目录中。"
                showExportSuccess = true
            }
        }
    }
    
    private func showReport() {
        let manager = ExportManager.shared
        let report = manager.generateReport(viewModel.transactions)
        exportMessage = report
        showExportSuccess = true
    }
    
    enum ExportFormat {
        case csv
        case json
    }
}

#Preview {
    SettingsView().environmentObject(TransactionViewModel())
}
