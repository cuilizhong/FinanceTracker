//
//  ExportManager.swift
//  FinanceTracker
//

import Foundation

class ExportManager {
    static let shared = ExportManager()
    
    /// 导出交易数据为 CSV 格式
    func exportToCSV(_ transactions: [Transaction]) -> URL? {
        var csvContent = "日期,金额,分类,类型,备注\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.date)
            let amount = String(format: "%.2f", transaction.amount)
            let category = transaction.category.rawValue
            let type = transaction.type.rawValue
            let note = transaction.note.replacingOccurrences(of: "\"", with: "\\\"")
            
            csvContent += "\(date),\(amount),\(category),\(type),\"\(note)\"\n"
        }
        
        let fileName = "FinanceTracker_\(Date().formatted(date: .abbreviated, time: .omitted)).csv"
        
        if let url = saveToFile(fileName, content: csvContent) {
            return url
        }
        return nil
    }
    
    /// 导出交易数据为 JSON 备份格式
    func exportToJSON(_ transactions: [Transaction]) -> URL? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            let data = try encoder.encode(transactions)
            let fileName = "FinanceTracker_Backup_\(Date().formatted(date: .abbreviated, time: .omitted)).json"
            
            if let url = saveToFile(fileName, data: data) {
                return url
            }
        } catch {
            print("❌ JSON编码失败: \(error.localizedDescription)")
        }
        return nil
    }
    
    /// 生成统计报告
    func generateReport(_ transactions: [Transaction]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        
        let income = transactions.filter { $0.type == .income }.map { $0.amount }.reduce(0, +)
        let expense = transactions.filter { $0.type == .expense }.map { $0.amount }.reduce(0, +)
        let balance = income - expense
        
        var report = "═══════════════════════════\n"
        report += "     财务追踪器 - 数据报告\n"
        report += "═══════════════════════════\n\n"
        
        report += "导出时间: \(dateFormatter.string(from: Date()))\n"
        report += "交易总数: \(transactions.count)\n\n"
        
        report += "─────────────────────────\n"
        report += "收支概览\n"
        report += "─────────────────────────\n"
        report += "总收入: ¥\(String(format: "%.2f", income))\n"
        report += "总支出: ¥\(String(format: "%.2f", expense))\n"
        report += "结余:   ¥\(String(format: "%.2f", balance))\n\n"
        
        // 分类统计
        var categoryTotals: [String: Double] = [:]
        for transaction in transactions.filter({ $0.type == .expense }) {
            categoryTotals[transaction.category.rawValue, default: 0] += transaction.amount
        }
        
        if !categoryTotals.isEmpty {
            report += "─────────────────────────\n"
            report += "分类支出明细\n"
            report += "─────────────────────────\n"
            
            let sorted = categoryTotals.sorted { $0.value > $1.value }
            for (category, amount) in sorted {
                let percentage = (amount / expense * 100)
                report += "\(category): ¥\(String(format: "%.2f", amount)) (\(String(format: "%.1f", percentage))%)\n"
            }
        }
        
        report += "\n═══════════════════════════\n"
        return report
    }
    
    // MARK: - 辅助方法
    
    private func saveToFile(_ fileName: String, content: String) -> URL? {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(fileName) else {
            return nil
        }
        
        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            print("✅ 文件已保存: \(url.lastPathComponent)")
            return url
        } catch {
            print("❌ 文件保存失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveToFile(_ fileName: String, data: Data) -> URL? {
        guard let url = getDocumentsDirectory()?.appendingPathComponent(fileName) else {
            return nil
        }
        
        do {
            try data.write(to: url)
            print("✅ 文件已保存: \(url.lastPathComponent)")
            return url
        } catch {
            print("❌ 文件保存失败: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
