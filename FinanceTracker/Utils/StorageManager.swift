//
//  StorageManager.swift
//  FinanceTracker
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let transactionsKey = "finance_tracker_transactions"
    private let firstLaunchKey = "finance_tracker_first_launch"
    
    /// 保存交易数组到本地存储
    func saveTransactions(_ transactions: [Transaction]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(transactions)
            UserDefaults.standard.set(data, forKey: transactionsKey)
        } catch {
            print("❌ 保存交易失败: \(error.localizedDescription)")
        }
    }
    
    /// 从本地存储加载交易数组
    func loadTransactions() -> [Transaction] {
        guard let data = UserDefaults.standard.data(forKey: transactionsKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let transactions = try decoder.decode([Transaction].self, from: data)
            return transactions
        } catch {
            print("❌ 加载交易失败: \(error.localizedDescription)")
            return []
        }
    }
    
    /// 检查是否为首次启动
    func isFirstLaunch() -> Bool {
        !UserDefaults.standard.bool(forKey: firstLaunchKey)
    }
    
    /// 标记已启动过应用
    func markAsLaunched() {
        UserDefaults.standard.set(true, forKey: firstLaunchKey)
    }
    
    /// 清空所有本地存储
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: transactionsKey)
        UserDefaults.standard.removeObject(forKey: firstLaunchKey)
    }
    
    /// 重置为样本数据
    func resetToSampleData(_ sampleData: [Transaction]) {
        saveTransactions(sampleData)
        markAsLaunched()
    }
}
