//
//  ContentView.swift
//  FinanceTracker
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAddTransaction = false
    @State private var fabPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 150)
    @EnvironmentObject var viewModel: TransactionViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(0)
                    .padding(.bottom, 100)
                
                AnalyticsView()
                    .tag(1)
                    .padding(.bottom, 100)
                
                SettingsView()
                    .tag(2)
                    .padding(.bottom, 100)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 0) {
                Button { selectedTab = 0 } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.pie.fill").font(.system(size: 20)).foregroundColor(selectedTab == 0 ? .blue : .gray)
                        Text("概览").font(.caption2).foregroundColor(selectedTab == 0 ? .blue : .gray)
                    }.frame(width: 70)
                }
                Spacer()
                Button { selectedTab = 1 } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill").font(.system(size: 20)).foregroundColor(selectedTab == 1 ? .blue : .gray)
                        Text("分析").font(.caption2).foregroundColor(selectedTab == 1 ? .blue : .gray)
                    }.frame(width: 70)
                }
                Spacer()
                Button { selectedTab = 2 } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill").font(.system(size: 20)).foregroundColor(selectedTab == 2 ? .blue : .gray)
                        Text("设置").font(.caption2).foregroundColor(selectedTab == 2 ? .blue : .gray)
                    }.frame(width: 70)
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // 浮动加号按钮 - 使用 ZStack 替代 Button，这样拖动手势会优先
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
    ContentView().environmentObject(TransactionViewModel())
}
