//
//  AnalyticsView.swift
//  FinanceTracker
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 时间段选择器（点击切换）
            PeriodSelectorView(selectedPeriod: $viewModel.selectedPeriod)
                .padding(.bottom, 12)
            
            // 使用 TabView 实现分页效果（支持滑动切换）
            TabView(selection: $viewModel.selectedPeriod) {
                // 周视图
                AnalyticsContentView()
                    .environmentObject(viewModel)
                    .tag(TransactionViewModel.TimePeriod.week)
                
                // 月视图
                AnalyticsContentView()
                    .environmentObject(viewModel)
                    .tag(TransactionViewModel.TimePeriod.month)
                
                // 年视图
                AnalyticsContentView()
                    .environmentObject(viewModel)
                    .tag(TransactionViewModel.TimePeriod.year)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)
        }
    }
}

// MARK: - 分析内容视图
struct AnalyticsContentView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 收支汇总卡片
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
                
                // 统计概览
                StatisticsCardView()
                    .environmentObject(viewModel)
                    .padding(.horizontal)
                
                // 日收支趋势图
                let chartData = viewModel.dailyTotals()
                LineChartView(
                    data: chartData,
                    title: "日均消费趋势",
                    color: .blue
                )
                .padding(.horizontal)
                
                // 分类支出饼图
                let categoryData = viewModel.expensesByCategory().map { ($0.0.rawValue, $0.1, $0.0.color) }
                PieChartView(data: categoryData, title: "分类支出占比")
                    .padding(.horizontal)
                
                // 分类排行榜
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("分类排行").font(.headline)
                        Spacer()
                        Text("TOP \(min(5, viewModel.expensesByCategory().count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.expensesByCategory().isEmpty {
                        Text("暂无数据").font(.subheadline).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.topCategories(limit: 5).enumerated()), id: \.offset) { index, item in
                                HStack(spacing: 12) {
                                    // 排名
                                    Text("#\(index + 1)")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    // 分类图标
                                    Circle()
                                        .fill(item.0.color.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Image(systemName: item.0.icon)
                                                .foregroundColor(item.0.color)
                                                .font(.system(size: 18))
                                        }
                                    
                                    // 分类名称和金额
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.0.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        let total = viewModel.expensesByCategory().map { $0.1 }.reduce(0, +)
                                        let percentage = total > 0 ? (item.1 / total * 100) : 0
                                        Text("\(String(format: "%.1f", percentage))%")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // 金额和进度条
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("¥\(Int(item.1))")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        // 进度条
                                        let total = viewModel.expensesByCategory().map { $0.1 }.reduce(0, +)
                                        let progress = total > 0 ? item.1 / total : 0
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(.systemGray5))
                                                
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(item.0.color)
                                                    .frame(width: geometry.size.width * progress)
                                            }
                                        }
                                        .frame(height: 6)
                                        .frame(width: 60)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - 统计卡片视图
struct StatisticsCardView: View {
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var avgDailyExpense: Double {
        let filtered = viewModel.filterTransactions()
        let expenses = filtered.filter { $0.type == .expense }
        
        if expenses.isEmpty { return 0 }
        
        // 计算跨度天数
        let dates = Set(expenses.map { Calendar.current.startOfDay(for: $0.date) })
        let daySpan = max(1, dates.count)
        
        return expenses.map { $0.amount }.reduce(0, +) / Double(daySpan)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "平均日消费",
                    value: "¥\(Int(avgDailyExpense))",
                    color: .orange
                )
                
                StatCard(
                    icon: "tag.circle.fill",
                    title: "分类数",
                    value: "\(viewModel.expensesByCategory().count)",
                    color: .purple
                )
                
                StatCard(
                    icon: "calendar",
                    title: "交易笔数",
                    value: "\(viewModel.filterTransactions().count)",
                    color: .green
                )
            }
        }
    }
}

// MARK: - 统计卡片
struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
    }
}

// MARK: - 时间段选择器
struct PeriodSelectorView: View {
    @Binding var selectedPeriod: TransactionViewModel.TimePeriod
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("数据分析").font(.system(size: 20, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // 自定义选项卡 - 更平滑的动画和间距
            HStack(spacing: 12) {
                ForEach(TransactionViewModel.TimePeriod.allCases, id: \.self) { period in
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedPeriod = period
                        }
                    } label: {
                        Text(period.rawValue)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(selectedPeriod == period ? .white : .gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                Group {
                                    if selectedPeriod == period {
                                        // 选中状态：蓝紫渐变 + 阴影
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ))
                                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                    } else {
                                        // 未选中状态：浅灰色背景
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color(.systemGray6))
                                    }
                                }
                            )
                            .scaleEffect(selectedPeriod == period ? 1.02 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    AnalyticsView().environmentObject(TransactionViewModel())
}
