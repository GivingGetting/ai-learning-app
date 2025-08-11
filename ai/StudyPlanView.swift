//
//  StudyPlanView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct StudyPlanView: View {
    @StateObject private var planManager = StudyPlanManager()
    @State private var showingTemplateSelection = false
    @State private var selectedPlan: StudyPlan?
    @State private var searchText = ""
    @State private var selectedFilter: PlanFilter = .all
    
    enum PlanFilter: String, CaseIterable {
        case all = "全部"
        case active = "进行中"
        case completed = "已完成"
        case pending = "待开始"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索和筛选栏
                searchAndFilterSection
                
                // 统计概览
                if !planManager.studyPlans.isEmpty {
                    statisticsSection
                }
                
                // 计划列表
                plansListSection
                
                Spacer()
            }
            .navigationTitle("学习计划")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingTemplateSelection = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .sheet(isPresented: $showingTemplateSelection) {
            TemplateSelectionView(planManager: planManager)
        }
        .sheet(item: $selectedPlan) { plan in
            StudyPlanDetailView(plan: plan, planManager: planManager)
        }
    }
    
    // MARK: - 搜索和筛选区域
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索学习计划...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            // 筛选器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PlanFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter,
                            action: {
                                selectedFilter = filter
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 统计概览区域
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            Text("学习概览")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "总计划",
                    value: "\(planManager.getTotalPlansCount())",
                    icon: "list.bullet.clipboard",
                    color: .blue
                )
                
                StatCard(
                    title: "进行中",
                    value: "\(planManager.getActivePlansCount())",
                    icon: "play.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "已完成",
                    value: "\(planManager.getCompletedPlansCount())",
                    icon: "checkmark.circle.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "平均进度",
                    value: "\(Int(planManager.getAverageProgress() * 100))%",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - 计划列表区域
    private var plansListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if planManager.studyPlans.isEmpty {
                emptyStateView
            } else {
                Text("我的计划")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPlans) { plan in
                            StudyPlanCard(plan: plan) {
                                selectedPlan = plan
                            }
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
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("还没有学习计划")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("点击右上角的 + 按钮创建你的第一个学习计划")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingTemplateSelection = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("创建学习计划")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 筛选后的计划
    private var filteredPlans: [StudyPlan] {
        let plans = planManager.studyPlans
        
        let filteredBySearch = searchText.isEmpty ? plans : plans.filter { plan in
            plan.title.localizedCaseInsensitiveContains(searchText) ||
            plan.description.localizedCaseInsensitiveContains(searchText) ||
            plan.category.localizedCaseInsensitiveContains(searchText) ||
            plan.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch selectedFilter {
        case .all:
            return filteredBySearch
        case .active:
            return filteredBySearch.filter { $0.isActive && $0.progress < 1.0 }
        case .completed:
            return filteredBySearch.filter { $0.progress >= 1.0 }
        case .pending:
            return filteredBySearch.filter { !$0.isActive }
        }
    }
}

// MARK: - 筛选器芯片
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - 学习计划卡片
struct StudyPlanCard: View {
    let plan: StudyPlan
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 标题和状态
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(plan.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // 状态指示器
                    VStack(spacing: 4) {
                        Circle()
                            .fill(plan.isActive ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)
                        
                        Text(plan.isActive ? "进行中" : "暂停")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 标签和难度
                HStack {
                    ForEach(plan.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    Text(plan.difficulty)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(plan.difficulty).opacity(0.2))
                        .foregroundColor(difficultyColor(plan.difficulty))
                        .cornerRadius(8)
                }
                
                // 进度和时间信息
                VStack(spacing: 8) {
                    HStack {
                        Text("进度: \(Int(plan.progress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("剩余 \(plan.remainingDays) 天")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ProgressView(value: plan.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                
                // 任务统计
                HStack {
                    Label("\(plan.completedTasksCount)/\(plan.totalTasksCount) 任务", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(plan.estimatedDuration) 天")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
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

struct StudyPlanView_Previews: PreviewProvider {
    static var previews: some View {
        StudyPlanView()
    }
}
