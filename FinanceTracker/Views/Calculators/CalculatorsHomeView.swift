//
//  CalculatorsHomeView.swift
//  FinanceTracker
//

import SwiftUI

struct CalculatorsHomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("理财计算器")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: InvestmentCalculatorView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text("💰")
                                            .font(.title)
                                        Text("投资计算器")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Text("一次性投资、定期投资计算")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .foregroundColor(.primary)
                        }
                        
                        NavigationLink(destination: SavingsCalculatorView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text("🏦")
                                            .font(.title)
                                        Text("存款计算器")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Text("定期存款、理财产品收益计算")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .foregroundColor(.primary)
                        }
                        
                        NavigationLink(destination: CompoundInterestView()) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Text("📈")
                                            .font(.title)
                                        Text("复利计算器")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Text("展示复利威力、对比不同频率")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                            .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("工具")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CalculatorsHomeView()
}
