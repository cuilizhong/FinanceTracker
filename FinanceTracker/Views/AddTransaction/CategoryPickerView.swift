//
//  CategoryPickerView.swift
//  FinanceTracker
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: Category
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("选择分类").font(.headline)
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            Divider()
            
            // 分类网格
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryPickerItem(
                            category: category,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = category
                                dismiss()
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct CategoryPickerItem: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .overlay {
                        Image(systemName: category.icon)
                            .font(.system(size: 20))
                            .foregroundColor(category.color)
                    }
                    .frame(height: 50)
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

#Preview {
    @State var selected = Category.food
    return CategoryPickerView(selectedCategory: $selected)
}
