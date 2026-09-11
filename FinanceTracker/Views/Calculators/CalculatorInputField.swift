//
//  CalculatorInputField.swift
//  FinanceTracker
//

import SwiftUI

struct CalculatorInputField: View {
    let label: String
    @Binding var value: String
    let placeholder: String
    let suffix: String?
    let keyboardType: UIKeyboardType
    
    init(label: String, value: Binding<String>, placeholder: String = "", suffix: String? = nil, keyboardType: UIKeyboardType = .decimalPad) {
        self.label = label
        self._value = value
        self.placeholder = placeholder
        self.suffix = suffix
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                TextField(placeholder, text: $value)
                    .keyboardType(keyboardType)
                    .font(.system(size: 16, weight: .semibold))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if let suffix = suffix {
                    Text(suffix)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(width: 30)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

#Preview {
    CalculatorInputField(label: "初始投资额", value: .constant("100000"), placeholder: "请输入金额", suffix: "元")
}
