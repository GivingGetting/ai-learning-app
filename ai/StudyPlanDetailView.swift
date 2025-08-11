//
//  StudyPlanDetailView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct StudyPlanDetailView: View {
    let plan: StudyPlan
    @ObservedObject var planManager: StudyPlanManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var selectedTask: StudyTask?
    @State private var showingTaskDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 计划概览
                    planOverviewSection
                    
                    // 进度统计
                    progressSection
                    
                    // 任务列表
                    tasksSection
                    
                    // 时间线
                    timelineSection
                    
                    // 笔记
                    if !plan.notes.isEmpty {
                        notesSection
                    }
                }
                .padding()
            }
            .navigationTitle("计划详情")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Label("编辑计划", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            planManager.togglePlanStatus(plan)
                        }) {
                            Label(plan.isActive ? "暂停计划" : "启动计划", 
                                  systemImage: plan.isActive ? "pause.circle" : "play.circle")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Label("删除计划", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditStudyPlanView(plan: plan, planManager: planManager)
        }
        .sheet(item: $selectedTask) { task in
            TaskDetailView(task: task, plan: plan, planManager: planManager)
        }
        .alert("删除学习计划", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) {
                planManager.deleteStudyPlan(plan)
                dismiss()
            }
        } message: {
            Text("确定要删除这个学习计划吗？此操作无法撤销。")
        }
    }
    
    // MARK: - 计划概览区域
    private var planOverviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题和状态
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(plan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                // 状态指示器
                VStack(spacing: 4) {
                    Circle()
                        .fill(plan.isActive ? Color.green : Color.gray)
                        .frame(width: 16, height: 16)
                    
                    Text(plan.isActive ? "进行中" : "已暂停")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // 标签和难度
            HStack {
                ForEach(plan.tags, id: \.self) { tag in
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
            
            // 时间信息
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("开始时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(plan.startDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("目标完成")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(formatDate(plan.targetDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("剩余时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(plan.remainingDays) 天")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(plan.remainingDays < 7 ? .red : .primary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 进度统计区域
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习进度")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // 总体进度
                HStack {
                    Text("总体进度")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(plan.progress * 100))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: plan.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                // 任务统计
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(plan.completedTasksCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("已完成")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(plan.totalTasksCount - plan.completedTasksCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("待完成")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(plan.totalTasksCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("总任务")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 任务列表区域
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习任务")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(plan.tasks) { task in
                    TaskRow(
                        task: task,
                        onTap: {
                            selectedTask = task
                        },
                        onToggle: { isCompleted in
                            if isCompleted {
                                planManager.completeTask(task, in: plan)
                            } else {
                                planManager.uncompleteTask(task, in: plan)
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 时间线区域
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习时间线")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(Array(plan.tasks.enumerated()), id: \.element.id) { index, task in
                    HStack(spacing: 12) {
                        // 时间线指示器
                        VStack(spacing: 0) {
                            Circle()
                                .fill(task.isCompleted ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                            
                            if index < plan.tasks.count - 1 {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 2, height: 30)
                            }
                        }
                        
                        // 任务信息
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(task.isCompleted ? .secondary : .primary)
                                .strikethrough(task.isCompleted)
                            
                            Text("\(task.estimatedTime) 分钟")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 优先级指示器
                        Image(systemName: task.priority.icon)
                            .foregroundColor(task.priority.color)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 笔记区域
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习笔记")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(plan.notes)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    // MARK: - 辅助函数
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
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

// MARK: - 任务行
struct TaskRow: View {
    let task: StudyTask
    let onTap: () -> Void
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 完成状态切换
            Button(action: {
                onToggle(!task.isCompleted)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            // 任务信息
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .strikethrough(task.isCompleted)
                
                Text(task.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // 优先级和时间
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: task.priority.icon)
                        .foregroundColor(task.priority.color)
                        .font(.caption)
                    
                    Text(task.priority.rawValue)
                        .font(.caption2)
                        .foregroundColor(task.priority.color)
                }
                
                Text("\(task.estimatedTime)分钟")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct StudyPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StudyPlanDetailView(
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
