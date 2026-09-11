//
//  LineChartView.swift
//  FinanceTracker
//

import SwiftUI

struct LineChartView: View {
    let data: [(Date, Double)]
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            
            if data.isEmpty {
                Text("暂无数据").font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 200)
            } else {
                Canvas { context, size in
                    let maxValue = (data.map { $0.1 }.max() ?? 100)
                    let minValue = (data.map { $0.1 }.min() ?? 0)
                    let range = maxValue - minValue > 0 ? maxValue - minValue : 100
                    
                    // 留出空间给边缘的数据点
                    let pointRadius: CGFloat = 4
                    let padding: CGFloat = pointRadius + 2
                    let chartWidth = size.width - 2 * padding
                    let chartHeight = size.height - 40  // 上下留白
                    
                    var path = Path()
                    let stepX = chartWidth / CGFloat(max(data.count - 1, 1))
                    
                    // 绘制数据点和连接线
                    for (index, (_, value)) in data.enumerated() {
                        let x = padding + CGFloat(index) * stepX
                        let y = size.height - ((value - minValue) / range) * chartHeight - 20
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    
                    // 绘制线条
                    context.stroke(
                        path,
                        with: .color(color),
                        lineWidth: 2
                    )
                    
                    // 绘制数据点
                    for (index, (_, value)) in data.enumerated() {
                        let x = padding + CGFloat(index) * stepX
                        let y = size.height - ((value - minValue) / range) * chartHeight - 20
                        
                        context.fill(
                            Path(ellipseIn: CGRect(x: x - pointRadius, y: y - pointRadius, width: pointRadius * 2, height: pointRadius * 2)),
                            with: .color(color)
                        )
                    }
                }
                .frame(height: 200)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 图例
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Circle().fill(color).frame(width: 8, height: 8)
                        Text("金额").font(.caption).foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("最高: ¥\(Int(data.map { $0.1 }.max() ?? 0))").font(.caption2).foregroundColor(.secondary)
                            Text("最低: ¥\(Int(data.map { $0.1 }.min() ?? 0))").font(.caption2).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("平均: ¥\(Int(data.map { $0.1 }.reduce(0, +) / Double(data.count)))").font(.caption2).foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)))
    }
}

#Preview {
    let sampleData = [
        (Date().addingTimeInterval(-86400 * 6), 1200.0),
        (Date().addingTimeInterval(-86400 * 5), 1500.0),
        (Date().addingTimeInterval(-86400 * 4), 900.0),
        (Date().addingTimeInterval(-86400 * 3), 2100.0),
        (Date().addingTimeInterval(-86400 * 2), 1800.0),
        (Date().addingTimeInterval(-86400), 1600.0),
        (Date(), 2000.0),
    ]
    
    LineChartView(data: sampleData, title: "7日支出趋势", color: .blue)
        .padding()
}
