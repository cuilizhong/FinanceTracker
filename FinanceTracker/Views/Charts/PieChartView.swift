//
//  PieChartView.swift
//  FinanceTracker
//

import SwiftUI

struct PieChartView: View {
    let data: [(String, Double, Color)]
    let title: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            
            if data.isEmpty {
                Text("暂无数据").font(.subheadline).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 200)
            } else {
                HStack(spacing: 20) {
                    // 饼图
                    Canvas { context, size in
                        let total = data.map { $0.1 }.reduce(0, +)
                        guard total > 0 else { return }
                        
                        var startAngle: Double = -90
                        
                        for (_, value, color) in data {
                            let angle = (value / total) * 360
                            
                            var path = Path()
                            path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
                            path.addArc(
                                center: CGPoint(x: size.width / 2, y: size.height / 2),
                                radius: size.width / 2 - 10,
                                startAngle: .degrees(startAngle),
                                endAngle: .degrees(startAngle + angle),
                                clockwise: false
                            )
                            path.closeSubpath()
                            
                            context.fill(path, with: .color(color))
                            startAngle += angle
                        }
                    }
                    .frame(width: 150, height: 150)
                    
                    // 图例
                    VStack(alignment: .leading, spacing: 8) {
                        let total = data.map { $0.1 }.reduce(0, +)
                        
                        ForEach(Array(data.enumerated()), id: \.offset) { _, item in
                            HStack(spacing: 8) {
                                Circle().fill(item.2).frame(width: 8, height: 8)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.0).font(.caption).fontWeight(.medium)
                                    let percentage = (item.1 / total * 100)
                                    Text("\(String(format: "%.1f", percentage))%")
                                        .font(.caption2).foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("¥\(Int(item.1))").font(.caption).fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemBackground)))
    }
}

#Preview {
    let sampleData = [
        ("食物", 1200.0, Color.blue),
        ("购物", 800.0, Color.purple),
        ("交通", 500.0, Color.orange),
        ("娱乐", 600.0, Color.pink),
    ]
    
    PieChartView(data: sampleData, title: "分类支出占比")
        .padding()
}
