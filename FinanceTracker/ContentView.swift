//
//  ContentView.swift
//  FinanceTracker
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showAddTransaction = false
    @State private var fabPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 150)
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 使用原生 TabView 配合 .tabViewStyle(.automatic) 实现标准 iOS TabBar
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem {
                        Label("概览", systemImage: "chart.pie.fill")
                    }
                    .tag(0)
                
                AnalyticsView()
                    .tabItem {
                        Label("分析", systemImage: "chart.bar.fill")
                    }
                    .tag(1)
                
                CalculatorsHomeView()
                    .tabItem {
                        Label("工具", systemImage: "function")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tabViewStyle(.automatic)  // 使用自动样式（iOS 标准 TabBar）
            
            // 浮动加号按钮 - 支持拖动
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 60, height: 60)
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .position(fabPosition)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        fabPosition = value.location
                    }
                    .onEnded { _ in
                        snapFABToEdge()
                    }
            )
            .onTapGesture {
                showAddTransaction = true
            }
            .zIndex(100)
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func snapFABToEdge() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // 如果更靠近左边，贴左边；否则贴右边
        let newX = fabPosition.x < screenWidth / 2 ? 40 : screenWidth - 40
        
        // 确保 Y 坐标在安全范围内
        let newY = min(max(fabPosition.y, 100), screenHeight - 150)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            fabPosition = CGPoint(x: newX, y: newY)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TransactionViewModel())
}
