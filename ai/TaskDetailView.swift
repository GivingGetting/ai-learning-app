//
//  TaskDetailView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct TaskDetailView: View {
    let task: StudyTask
    let plan: StudyPlan
    @ObservedObject var planManager: StudyPlanManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 任务概览
                    taskOverviewSection
                    
                    // 任务详情
                    taskDetailsSection
                    
                    // 完成状态
                    completionSection
                    
                    // 依赖关系
                    if !task.dependencies.isEmpty {
                        dependenciesSection
                    }
                    
                    // 时间估算
                    timeEstimationSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("任务详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        toggleTaskCompletion()
                    }) {
                        HStack {
                            Image(systemName: task.isCompleted ? "xmark.circle" : "checkmark.circle")
                            Text(task.isCompleted ? "标记未完成" : "标记完成")
                        }
                        .foregroundColor(task.isCompleted ? .orange : .green)
                    }
                }
            }
        }
    }
    
    // MARK: - 任务概览区域
    private var taskOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和状态
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .strikethrough(task.isCompleted)
                    
                    Text(task.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // 完成状态指示器
                VStack(spacing: 4) {
                    Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundColor(task.isCompleted ? .green : .gray)
                    
                    Text(task.isCompleted ? "已完成" : "待完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 优先级
            HStack {
                Text("优先级")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: task.priority.icon)
                        .foregroundColor(task.priority.color)
                        .font(.subheadline)
                    
                    Text(task.priority.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(task.priority.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.priority.color.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 任务详情区域
    private var taskDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("任务详情")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(task.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                
                // 任务类型指示器
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.blue)
                    
                    Text("学习任务")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 完成状态区域
    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("完成状态")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("状态")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(task.isCompleted ? "已完成" : "进行中")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(task.isCompleted ? .green : .orange)
                }
                
                if let completedDate = task.completedDate {
                    HStack {
                        Text("完成时间")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(formatDate(completedDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 完成进度指示器
                HStack {
                    Text("进度")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(task.isCompleted ? 100 : 0)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: task.isCompleted ? 1.0 : 0.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 依赖关系区域
    private var dependenciesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("依赖任务")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                ForEach(task.dependencies, id: \.self) { dependencyId in
                    if let dependencyTask = plan.tasks.first(where: { $0.id == dependencyId }) {
                        HStack {
                            Image(systemName: dependencyTask.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(dependencyTask.isCompleted ? .green : .gray)
                            
                            Text(dependencyTask.title)
                                .font(.subheadline)
                                .foregroundColor(dependencyTask.isCompleted ? .secondary : .primary)
                                .strikethrough(dependencyTask.isCompleted)
                            
                            Spacer()
                            
                            Text(dependencyTask.isCompleted ? "已完成" : "待完成")
                                .font(.caption)
                                .foregroundColor(dependencyTask.isCompleted ? .green : .orange)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 时间估算区域
    private var timeEstimationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("时间估算")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("预计用时")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(task.estimatedTime) 分钟")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                // 时间可视化
                HStack(spacing: 8) {
                    ForEach(0..<min(task.estimatedTime / 30, 8), id: \.self) { _ in
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 20, height: 8)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                
                Text("建议：将任务分解为 \(max(1, task.estimatedTime / 30)) 个30分钟的学习时段")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 切换任务完成状态
    private func toggleTaskCompletion() {
        if task.isCompleted {
            planManager.uncompleteTask(task, in: plan)
        } else {
            planManager.completeTask(task, in: plan)
        }
        
        // 显示触觉反馈
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - 辅助函数
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(
            task: StudyTask(
                title: "测试任务",
                description: "这是一个测试学习任务",
                estimatedTime: 120,
                priority: .high
            ),
            plan: StudyPlan(
                title: "测试计划",
                description: "这是一个测试学习计划",
                category: "机器学习",
                difficulty: "初级",
                estimatedDuration: 21
            ),
            planManager: StudyPlanManager()
        )
    }
}
