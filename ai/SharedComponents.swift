//
//  SharedComponents.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

// MARK: - 通用统计项组件
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 带图标的统计项组件
struct IconStatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

// MARK: - 通用信息行组件
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 通用标签组件
struct DifficultyTag: View {
    let difficulty: CourseDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(difficulty.color).opacity(0.2))
            .foregroundColor(Color(difficulty.color))
            .cornerRadius(8)
    }
}

// MARK: - 通用进度条组件
struct ProgressBar: View {
    let value: Double
    let total: Double
    let color: Color
    
    var body: some View {
        ProgressView(value: value, total: total)
            .progressViewStyle(LinearProgressViewStyle(tint: color))
    }
}

// MARK: - 通用卡片组件
struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}
