//
//  TemplateSelectionView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct TemplateSelectionView: View {
    @ObservedObject var planManager: StudyPlanManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: String = "全部"
    @State private var selectedDifficulty: String = "全部"
    @State private var searchText = ""
    
    private var categories: [String] {
        ["全部"] + Array(Set(planManager.templates.map { $0.category })).sorted()
    }
    
    private var difficulties: [String] {
        ["全部"] + Array(Set(planManager.templates.map { $0.difficulty })).sorted()
    }
    
    private var filteredTemplates: [StudyPlanTemplate] {
        planManager.templates.filter { template in
            let matchesCategory = selectedCategory == "全部" || template.category == selectedCategory
            let matchesDifficulty = selectedDifficulty == "全部" || template.difficulty == selectedDifficulty
            let matchesSearch = searchText.isEmpty || 
                template.title.localizedCaseInsensitiveContains(searchText) ||
                template.description.localizedCaseInsensitiveContains(searchText) ||
                template.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            return matchesCategory && matchesDifficulty && matchesSearch
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                searchSection
                
                // 筛选器
                filterSection
                
                // 模板列表
                templatesListSection
                
                Spacer()
            }
            .navigationTitle("选择学习计划")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 搜索区域
    private var searchSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索模板...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
    
    // MARK: - 筛选区域
    private var filterSection: some View {
        VStack(spacing: 12) {
            // 类别筛选
            VStack(alignment: .leading, spacing: 8) {
                Text("学习领域")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            FilterChip(
                                title: category,
                                isSelected: selectedCategory == category,
                                action: {
                                    selectedCategory = category
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // 难度筛选
            VStack(alignment: .leading, spacing: 8) {
                Text("难度等级")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            FilterChip(
                                title: difficulty,
                                isSelected: selectedDifficulty == difficulty,
                                action: {
                                    selectedDifficulty = difficulty
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
    
    // MARK: - 模板列表区域
    private var templatesListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if filteredTemplates.isEmpty {
                emptyStateView
            } else {
                Text("推荐模板 (\(filteredTemplates.count))")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredTemplates) { template in
                            TemplateCard(
                                template: template,
                                onSelect: {
                                    createPlanFromTemplate(template)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("没有找到匹配的模板")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("尝试调整筛选条件或搜索关键词")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 创建计划
    private func createPlanFromTemplate(_ template: StudyPlanTemplate) {
        let plan = planManager.createStudyPlan(from: template)
        
        // 显示成功提示
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // 关闭视图
        dismiss()
    }
}

// MARK: - 模板卡片
struct TemplateCard: View {
    let template: StudyPlanTemplate
    let onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和描述
            VStack(alignment: .leading, spacing: 8) {
                Text(template.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(template.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // 标签和难度
            HStack {
                ForEach(template.tags.prefix(3), id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text(template.difficulty)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(difficultyColor(template.difficulty).opacity(0.2))
                    .foregroundColor(difficultyColor(template.difficulty))
                    .cornerRadius(8)
            }
            
            // 任务概览
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("任务概览")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(template.taskTemplates.count) 个任务")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 任务时间线预览
                VStack(spacing: 6) {
                    ForEach(template.taskTemplates.prefix(3), id: \.title) { task in
                        HStack {
                            Text("第\(task.week)周")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .frame(width: 40, alignment: .leading)
                            
                            Text(task.title)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(task.estimatedTime)分钟")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if template.taskTemplates.count > 3 {
                        Text("... 还有 \(template.taskTemplates.count - 3) 个任务")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            
            // 时间和操作
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("预计时长")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(template.estimatedDuration) 天")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Button(action: onSelect) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("选择此模板")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "初级":
            return .green
        case "中级":
            return .orange
        case "高级":
            return .red
        default:
            return .gray
        }
    }
}

struct TemplateSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplateSelectionView(planManager: StudyPlanManager())
    }
}
