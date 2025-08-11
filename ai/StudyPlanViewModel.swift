//
//  StudyPlanViewModel.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import Foundation
import SwiftUI

// MARK: - 学习计划模型
struct StudyPlan: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var category: String
    var difficulty: String
    var estimatedDuration: Int // 以天为单位
    var startDate: Date
    var targetDate: Date
    var isActive: Bool
    var progress: Double // 0.0 到 1.0
    var tasks: [StudyTask]
    var tags: [String]
    var notes: String
    
    init(title: String, description: String, category: String, difficulty: String, estimatedDuration: Int) {
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.estimatedDuration = estimatedDuration
        self.startDate = Date()
        self.targetDate = Calendar.current.date(byAdding: .day, value: estimatedDuration, to: Date()) ?? Date()
        self.isActive = true
        self.progress = 0.0
        self.tasks = []
        self.tags = []
        self.notes = ""
    }
    
    // 计算剩余天数
    var remainingDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: targetDate)
        return max(0, components.day ?? 0)
    }
    
    // 计算完成的任务数量
    var completedTasksCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    // 计算总任务数量
    var totalTasksCount: Int {
        tasks.count
    }
    
    // 更新进度
    mutating func updateProgress() {
        guard !tasks.isEmpty else {
            progress = 0.0
            return
        }
        progress = Double(completedTasksCount) / Double(totalTasksCount)
    }
}

// MARK: - 学习任务模型
struct StudyTask: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var estimatedTime: Int // 以分钟为单位
    var isCompleted: Bool
    var completedDate: Date?
    var priority: TaskPriority
    var dependencies: [UUID] // 依赖的任务ID
    
    enum TaskPriority: String, CaseIterable, Codable {
        case low = "低"
        case medium = "中"
        case high = "高"
        case critical = "紧急"
        
        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .blue
            case .high: return .orange
            case .critical: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "arrow.up.circle"
            case .critical: return "exclamationmark.triangle"
            }
        }
    }
    
    init(title: String, description: String, estimatedTime: Int, priority: TaskPriority = .medium) {
        self.title = title
        self.description = description
        self.estimatedTime = estimatedTime
        self.isCompleted = false
        self.priority = priority
        self.dependencies = []
    }
}

// MARK: - 学习计划模板
struct StudyPlanTemplate: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedDuration: Int
    let tags: [String]
    let taskTemplates: [StudyTaskTemplate]
    
    struct StudyTaskTemplate {
        let title: String
        let description: String
        let estimatedTime: Int
        let priority: StudyTask.TaskPriority
        let week: Int // 第几周开始
    }
}

// MARK: - 学习计划管理器
class StudyPlanManager: ObservableObject {
    @Published var studyPlans: [StudyPlan] = []
    @Published var templates: [StudyPlanTemplate] = []
    
    init() {
        loadStudyPlans()
        setupTemplates()
    }
    
    // MARK: - 计划管理
    func createStudyPlan(from template: StudyPlanTemplate) -> StudyPlan {
        var plan = StudyPlan(
            title: template.title,
            description: template.description,
            category: template.category,
            difficulty: template.difficulty,
            estimatedDuration: template.estimatedDuration
        )
        
        plan.tags = template.tags
        
        // 创建任务
        for taskTemplate in template.taskTemplates {
            let task = StudyTask(
                title: taskTemplate.title,
                description: taskTemplate.description,
                estimatedTime: taskTemplate.estimatedTime,
                priority: taskTemplate.priority
            )
            plan.tasks.append(task)
        }
        
        studyPlans.append(plan)
        saveStudyPlans()
        return plan
    }
    
    func updateStudyPlan(_ plan: StudyPlan) {
        if let index = studyPlans.firstIndex(where: { $0.id == plan.id }) {
            studyPlans[index] = plan
            saveStudyPlans()
        }
    }
    
    func deleteStudyPlan(_ plan: StudyPlan) {
        studyPlans.removeAll { $0.id == plan.id }
        saveStudyPlans()
    }
    
    func togglePlanStatus(_ plan: StudyPlan) {
        if let index = studyPlans.firstIndex(where: { $0.id == plan.id }) {
            studyPlans[index].isActive.toggle()
            saveStudyPlans()
        }
    }
    
    // MARK: - 任务管理
    func completeTask(_ task: StudyTask, in plan: StudyPlan) {
        guard let planIndex = studyPlans.firstIndex(where: { $0.id == plan.id }),
              let taskIndex = studyPlans[planIndex].tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        studyPlans[planIndex].tasks[taskIndex].isCompleted = true
        studyPlans[planIndex].tasks[taskIndex].completedDate = Date()
        studyPlans[planIndex].updateProgress()
        
        saveStudyPlans()
    }
    
    func uncompleteTask(_ task: StudyTask, in plan: StudyPlan) {
        guard let planIndex = studyPlans.firstIndex(where: { $0.id == plan.id }),
              let taskIndex = studyPlans[planIndex].tasks.firstIndex(where: { $0.id == task.id }) else { return }
        
        studyPlans[planIndex].tasks[taskIndex].isCompleted = false
        studyPlans[planIndex].tasks[taskIndex].completedDate = nil
        studyPlans[planIndex].updateProgress()
        
        saveStudyPlans()
    }
    
    // MARK: - 模板设置
    private func setupTemplates() {
        templates = [
            // 机器学习基础模板
            StudyPlanTemplate(
                title: "机器学习基础入门",
                description: "从零开始学习机器学习的基本概念和算法",
                category: "机器学习",
                difficulty: "初级",
                estimatedDuration: 21,
                tags: ["机器学习", "Python", "算法"],
                taskTemplates: [
                    .init(title: "数学基础复习", description: "复习线性代数、微积分、概率统计", estimatedTime: 120, priority: .high, week: 1),
                    .init(title: "Python环境搭建", description: "安装Python、NumPy、Pandas等库", estimatedTime: 60, priority: .high, week: 1),
                    .init(title: "监督学习概念", description: "学习监督学习的基本概念和类型", estimatedTime: 90, priority: .high, week: 2),
                    .init(title: "线性回归实践", description: "实现简单的线性回归算法", estimatedTime: 120, priority: .medium, week: 2),
                    .init(title: "逻辑回归学习", description: "理解逻辑回归原理和应用", estimatedTime: 90, priority: .medium, week: 3),
                    .init(title: "决策树算法", description: "学习决策树的工作原理", estimatedTime: 120, priority: .medium, week: 3),
                    .init(title: "支持向量机", description: "了解SVM的基本原理", estimatedTime: 150, priority: .medium, week: 4),
                    .init(title: "项目实践", description: "完成一个完整的机器学习项目", estimatedTime: 240, priority: .high, week: 4)
                ]
            ),
            
            // 深度学习模板
            StudyPlanTemplate(
                title: "深度学习专项训练",
                description: "深入学习神经网络和深度学习技术",
                category: "深度学习",
                difficulty: "中级",
                estimatedDuration: 28,
                tags: ["深度学习", "神经网络", "PyTorch"],
                taskTemplates: [
                    .init(title: "神经网络基础", description: "理解神经元、激活函数、反向传播", estimatedTime: 180, priority: .high, week: 1),
                    .init(title: "PyTorch入门", description: "学习PyTorch的基本操作", estimatedTime: 120, priority: .high, week: 1),
                    .init(title: "卷积神经网络", description: "学习CNN的原理和结构", estimatedTime: 240, priority: .high, week: 2),
                    .init(title: "图像分类项目", description: "使用CNN进行图像分类", estimatedTime: 300, priority: .high, week: 3),
                    .init(title: "循环神经网络", description: "理解RNN和LSTM", estimatedTime: 240, priority: .medium, week: 4),
                    .init(title: "序列数据处理", description: "处理文本和时序数据", estimatedTime: 180, priority: .medium, week: 4),
                    .init(title: "Transformer架构", description: "学习注意力机制", estimatedTime: 300, priority: .high, week: 5),
                    .init(title: "自然语言处理", description: "应用深度学习到NLP任务", estimatedTime: 240, priority: .medium, week: 6),
                    .init(title: "模型优化", description: "学习模型调优技巧", estimatedTime: 180, priority: .medium, week: 7),
                    .init(title: "综合项目", description: "完成一个完整的深度学习项目", estimatedTime: 360, priority: .high, week: 8)
                ]
            ),
            
            // NLP模板
            StudyPlanTemplate(
                title: "自然语言处理实战",
                description: "掌握NLP的核心技术和应用",
                category: "自然语言处理",
                difficulty: "中级",
                estimatedDuration: 21,
                tags: ["NLP", "文本处理", "语言模型"],
                taskTemplates: [
                    .init(title: "文本预处理", description: "学习文本清洗、分词、标准化", estimatedTime: 120, priority: .high, week: 1),
                    .init(title: "词向量技术", description: "理解Word2Vec、GloVe等", estimatedTime: 180, priority: .high, week: 1),
                    .init(title: "文本分类", description: "实现文本分类算法", estimatedTime: 240, priority: .medium, week: 2),
                    .init(title: "命名实体识别", description: "学习NER技术", estimatedTime: 180, priority: .medium, week: 2),
                    .init(title: "情感分析", description: "实现情感分析系统", estimatedTime: 240, priority: .medium, week: 3),
                    .init(title: "机器翻译", description: "了解机器翻译原理", estimatedTime: 300, priority: .high, week: 3),
                    .init(title: "预训练模型", description: "学习BERT、GPT等模型", estimatedTime: 360, priority: .high, week: 4),
                    .init(title: "NLP项目", description: "完成NLP应用项目", estimatedTime: 300, priority: .high, week: 5)
                ]
            ),
            
            // 计算机视觉模板
            StudyPlanTemplate(
                title: "计算机视觉进阶",
                description: "深入学习图像处理和计算机视觉技术",
                category: "计算机视觉",
                difficulty: "中级",
                estimatedDuration: 24,
                tags: ["计算机视觉", "图像处理", "OpenCV"],
                taskTemplates: [
                    .init(title: "图像处理基础", description: "学习图像的基本操作和处理", estimatedTime: 120, priority: .high, week: 1),
                    .init(title: "OpenCV入门", description: "掌握OpenCV的基本功能", estimatedTime: 180, priority: .high, week: 1),
                    .init(title: "特征提取", description: "学习SIFT、SURF等特征", estimatedTime: 240, priority: .medium, week: 2),
                    .init(title: "目标检测", description: "理解目标检测算法", estimatedTime: 300, priority: .high, week: 3),
                    .init(title: "图像分割", description: "学习语义分割技术", estimatedTime: 300, priority: .medium, week: 4),
                    .init(title: "人脸识别", description: "实现人脸识别系统", estimatedTime: 360, priority: .high, week: 5),
                    .init(title: "视频处理", description: "处理视频数据", estimatedTime: 240, priority: .medium, week: 6),
                    .init(title: "CV项目", description: "完成计算机视觉项目", estimatedTime: 300, priority: .high, week: 7)
                ]
            )
        ]
    }
    
    // MARK: - 数据持久化
    private func saveStudyPlans() {
        if let encoded = try? JSONEncoder().encode(studyPlans) {
            UserDefaults.standard.set(encoded, forKey: "StudyPlans")
        }
    }
    
    private func loadStudyPlans() {
        if let data = UserDefaults.standard.data(forKey: "StudyPlans"),
           let decoded = try? JSONDecoder().decode([StudyPlan].self, from: data) {
            studyPlans = decoded
        }
    }
    
    // MARK: - 统计信息
    func getActivePlansCount() -> Int {
        studyPlans.filter { $0.isActive }.count
    }
    
    func getCompletedPlansCount() -> Int {
        studyPlans.filter { $0.progress >= 1.0 }.count
    }
    
    func getTotalPlansCount() -> Int {
        studyPlans.count
    }
    
    func getAverageProgress() -> Double {
        guard !studyPlans.isEmpty else { return 0.0 }
        let totalProgress = studyPlans.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(studyPlans.count)
    }
    
    func getPlansByCategory() -> [String: [StudyPlan]] {
        Dictionary(grouping: studyPlans) { $0.category }
    }
    
    func getPlansByDifficulty() -> [String: [StudyPlan]] {
        Dictionary(grouping: studyPlans) { $0.difficulty }
    }
}
