//
//  EditStudyPlanView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct EditStudyPlanView: View {
    let plan: StudyPlan
    @ObservedObject var planManager: StudyPlanManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var notes: String
    @State private var isActive: Bool
    @State private var targetDate: Date
    @State private var showingSaveAlert = false
    
    init(plan: StudyPlan, planManager: StudyPlanManager) {
        self.plan = plan
        self.planManager = planManager
        self._title = State(initialValue: plan.title)
        self._description = State(initialValue: plan.description)
        self._notes = State(initialValue: plan.notes)
        self._isActive = State(initialValue: plan.isActive)
        self._targetDate = State(initialValue: plan.targetDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本信息
                Section("基本信息") {
                    TextField("计划标题", text: $title)
                    
                    TextField("计划描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // 状态设置
                Section("计划状态") {
                    Toggle("激活计划", isOn: $isActive)
                    
                    DatePicker("目标完成日期", selection: $targetDate, displayedComponents: .date)
                }
                
                // 学习笔记
                Section("学习笔记") {
                    TextField("添加学习笔记...", text: $notes, axis: .vertical)
                        .lineLimit(5...10)
                }
                
                // 计划信息（只读）
                Section("计划信息") {
                    HStack {
                        Text("学习领域")
                        Spacer()
                        Text(plan.category)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("难度等级")
                        Spacer()
                        Text(plan.difficulty)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("预计时长")
                        Spacer()
                        Text("\(plan.estimatedDuration) 天")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开始时间")
                        Spacer()
                        Text(formatDate(plan.startDate))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("任务数量")
                        Spacer()
                        Text("\(plan.totalTasksCount) 个")
                            .foregroundColor(.secondary)
                    }
                }
                
                // 标签信息
                if !plan.tags.isEmpty {
                    Section("学习标签") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(plan.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 30)
                    }
                }
            }
            .navigationTitle("编辑计划")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .alert("保存成功", isPresented: $showingSaveAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("学习计划已成功更新")
        }
    }
    
    // MARK: - 保存更改
    private func saveChanges() {
        var updatedPlan = plan
        
        updatedPlan.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedPlan.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedPlan.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedPlan.isActive = isActive
        updatedPlan.targetDate = targetDate
        
        planManager.updateStudyPlan(updatedPlan)
        
        // 显示成功提示
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        showingSaveAlert = true
    }
    
    // MARK: - 辅助函数
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct EditStudyPlanView_Previews: PreviewProvider {
    static var previews: some View {
        EditStudyPlanView(
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
