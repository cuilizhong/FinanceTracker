//
//  Category.swift
//  FinanceTracker
//

import SwiftUI

enum Category: String, Codable, CaseIterable {
    case food = "餐饮"
    case shopping = "购物"
    case transportation = "交通"
    case entertainment = "娱乐"
    case health = "医疗"
    case education = "教育"
    case housing = "住房"
    case utilities = "水电"
    case salary = "工资"
    case freelance = "兼职"
    case investment = "投资"
    case other = "其他"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .shopping: return "cart.fill"
        case .transportation: return "car.fill"
        case .entertainment: return "film.fill"
        case .health: return "heart.fill"
        case .education: return "book.fill"
        case .housing: return "house.fill"
        case .utilities: return "bolt.fill"
        case .salary: return "banknote.fill"
        case .freelance: return "briefcase.fill"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return Color.orange
        case .shopping: return Color.pink
        case .transportation: return Color.blue
        case .entertainment: return Color.purple
        case .health: return Color.red
        case .education: return Color.green
        case .housing: return Color.brown
        case .utilities: return Color.cyan
        case .salary: return Color.mint
        case .freelance: return Color.indigo
        case .investment: return Color.teal
        case .other: return Color.gray
        }
    }
    
    var gradient: LinearGradient {
        LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
