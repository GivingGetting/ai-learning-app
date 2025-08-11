//
//  AIChatViewModel.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import Foundation
import SwiftUI

// MARK: - AI聊天消息模型
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    enum MessageType: String, CaseIterable, Codable {
        case text = "文本"
        case image = "图片"
        case code = "代码"
        case suggestion = "建议"
        case learningPath = "学习路径"
    }
}

// MARK: - 学习建议模型
struct LearningSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedTime: String
}

// MARK: - AI聊天视图模型
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var showingSuggestions: Bool = false
    @Published var showingLearningPath: Bool = false
    
    // 用户进度引用
    var userProgress: UserProgress?
    
    // 预设的学习建议
    let learningSuggestions = [
        LearningSuggestion(
            title: "机器学习基础",
            description: "从监督学习开始，掌握核心概念",
            category: "机器学习",
            difficulty: "初级",
            estimatedTime: "2-3周"
        ),
        LearningSuggestion(
            title: "深度学习入门",
            description: "学习神经网络和深度学习原理",
            category: "深度学习",
            difficulty: "中级",
            estimatedTime: "4-6周"
        ),
        LearningSuggestion(
            title: "自然语言处理",
            description: "让计算机理解人类语言",
            category: "NLP",
            difficulty: "中级",
            estimatedTime: "3-4周"
        ),
        LearningSuggestion(
            title: "计算机视觉",
            description: "图像识别和分析技术",
            category: "计算机视觉",
            difficulty: "中级",
            estimatedTime: "3-4周"
        ),
        LearningSuggestion(
            title: "强化学习",
            description: "通过试错学习最优策略",
            category: "强化学习",
            difficulty: "中级",
            estimatedTime: "4-5周"
        ),
        LearningSuggestion(
            title: "AI伦理与未来",
            description: "思考AI发展的社会责任",
            category: "AI伦理",
            difficulty: "高级",
            estimatedTime: "2-3周"
        )
    ]
    
    // 快速问题模板
    let quickQuestions = [
        "什么是机器学习？",
        "深度学习与传统机器学习的区别？",
        "如何开始学习AI？",
        "推荐一些AI学习资源",
        "解释神经网络原理",
        "什么是过拟合？如何避免？",
        "AI在医疗健康中的应用",
        "大语言模型的工作原理",
        "帮我制定学习计划",
        "如何安排学习时间？"
    ]
    
    init(userProgress: UserProgress? = nil) {
        self.userProgress = userProgress
        
        // 添加欢迎消息
        let welcomeMessage = ChatMessage(
            content: "你好！我是你的AI学习助手 🤖\n\n我可以帮你：\n• 解答AI相关问题\n• 制定学习计划\n• 推荐学习资源\n• 分析学习进度\n• 提供学习建议\n\n有什么可以帮助你的吗？",
            isUser: false,
            timestamp: Date(),
            messageType: .text
        )
        messages.append(welcomeMessage)
    }
    
    // MARK: - 消息管理
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = ChatMessage(
            content: inputText,
            isUser: true,
            timestamp: Date(),
            messageType: .text
        )
        
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        
        // 记录AI聊天统计
        userProgress?.recordAIChat()
        
        // 模拟AI响应
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateAIResponse(to: userInput)
            self.isLoading = false
        }
    }
    
    func sendSuggestion(_ suggestion: String) {
        inputText = suggestion
        sendMessage()
    }
    
    func sendQuickQuestion(_ question: String) {
        inputText = question
        sendMessage()
    }
    
    // MARK: - AI响应生成
    private func generateAIResponse(to userInput: String) {
        let response: String
        
        let lowercasedInput = userInput.lowercased()
        
        if lowercasedInput.contains("你好") || lowercasedInput.contains("hello") {
            response = "你好！很高兴见到你！我是专门为AI学习设计的助手，可以帮你解答AI相关的问题，制定学习计划，推荐学习资源。你想了解AI的哪个方面呢？"
        } else if lowercasedInput.contains("机器学习") || lowercasedInput.contains("machine learning") {
            response = "机器学习是人工智能的一个重要分支，它让计算机能够从数据中学习并改进，而无需明确编程。\n\n主要类型包括：\n• 监督学习：使用标记数据训练\n• 无监督学习：发现数据中的模式\n• 强化学习：通过试错学习\n\n你想深入了解哪个方面？"
        } else if lowercasedInput.contains("深度学习") || lowercasedInput.contains("deep learning") {
            response = "深度学习是机器学习的一个子集，使用多层神经网络来模拟人脑的学习过程。\n\n核心特点：\n• 多层神经网络结构\n• 自动特征提取\n• 端到端学习\n• 大数据驱动\n\n在图像识别、自然语言处理、语音识别等领域取得了突破性进展。"
        } else if lowercasedInput.contains("神经网络") || lowercasedInput.contains("neural network") {
            response = "神经网络是受生物神经元启发的计算模型，由相互连接的节点组成。\n\n基本组成：\n• 输入层：接收数据\n• 隐藏层：处理信息\n• 输出层：产生结果\n• 权重：连接强度\n• 激活函数：非线性变换\n\n它们能够学习复杂的模式，是现代AI系统的核心。"
        } else if lowercasedInput.contains("学习计划") || lowercasedInput.contains("计划") {
            response = "我来帮你制定一个AI学习计划！\n\n📚 初级阶段（1-2个月）：\n• 数学基础：线性代数、微积分、概率统计\n• 编程基础：Python、NumPy、Pandas\n• 机器学习基础概念\n\n🚀 中级阶段（3-6个月）：\n• 经典算法：线性回归、决策树、SVM\n• 深度学习框架：TensorFlow/PyTorch\n• 项目实践\n\n🎯 高级阶段（6个月+）：\n• 专业领域：CV、NLP、RL\n• 论文阅读\n• 开源项目贡献\n\n你想从哪个阶段开始？"
        } else if lowercasedInput.contains("资源") || lowercasedInput.contains("推荐") {
            response = "📖 推荐学习资源：\n\n📚 书籍：\n• 《机器学习》- 周志华\n• 《深度学习》- Ian Goodfellow\n• 《Python机器学习》- Sebastian Raschka\n\n🌐 在线课程：\n• Coursera: 机器学习专项课程\n• edX: MIT 6.S191\n• 吴恩达深度学习课程\n\n💻 实践平台：\n• Kaggle: 数据科学竞赛\n• GitHub: 开源项目\n• Colab: 免费GPU资源\n\n你想了解哪个资源的具体信息？"
        } else if lowercasedInput.contains("反向传播") || lowercasedInput.contains("backpropagation") {
            response = """
            反向传播是训练神经网络的核心算法！
            
            🔄 工作原理：
            1. 前向传播：计算预测值
            2. 计算损失：预测值与真实值的差异
            3. 反向传播：计算梯度
            4. 参数更新：使用梯度下降
            
            📊 关键概念：
            • 链式法则
            • 梯度下降
            • 学习率
            • 批量大小
            
            这个算法让神经网络能够"学习"和"改进"！
            """
        } else if lowercasedInput.contains("过拟合") || lowercasedInput.contains("overfitting") {
            response = """
            过拟合是机器学习中的常见问题！
            
            ⚠️ 什么是过拟合：
            模型在训练数据上表现很好，但在新数据上表现差
            
            🔧 解决方法：
            • 增加训练数据
            • 正则化（L1/L2）
            • Dropout
            • 早停法
            • 交叉验证
            
            💡 简单理解：模型"记住"了训练数据，但没有"理解"数据模式
            """
        } else if lowercasedInput.contains("项目") || lowercasedInput.contains("实践") {
            response = "🎯 推荐AI实践项目：\n\n🌱 入门级：\n• 手写数字识别（MNIST）\n• 房价预测\n• 垃圾邮件分类\n\n🚀 进阶级：\n• 图像分类器\n• 情感分析\n• 推荐系统\n\n🔥 高级：\n• 目标检测\n• 机器翻译\n• 语音识别\n\n建议从简单的项目开始，逐步增加复杂度。你想尝试哪个项目？"
        } else if lowercasedInput.contains("医疗") || lowercasedInput.contains("健康") {
            response = "🏥 AI在医疗健康领域的应用非常广泛：\n\n🔬 医学影像分析：\n• X光片诊断\n• CT扫描分析\n• MRI图像处理\n\n💊 药物发现：\n• 分子设计\n• 药物筛选\n• 临床试验优化\n\n📊 健康管理：\n• 疾病预测\n• 个性化治疗\n• 健康监测\n\n这些应用正在改变医疗行业，提高诊断准确性和治疗效果。"
        } else if lowercasedInput.contains("金融") || lowercasedInput.contains("投资") {
            response = "💰 AI在金融科技领域的应用：\n\n📈 风险评估：\n• 信用评分\n• 欺诈检测\n• 市场风险分析\n\n🤖 智能投顾：\n• 投资组合优化\n• 个性化建议\n• 自动交易\n\n📊 数据分析：\n• 市场预测\n• 客户行为分析\n• 合规监控\n\nAI正在重塑金融服务，提高效率和准确性。"
        } else if lowercasedInput.contains("自动驾驶") || lowercasedInput.contains("汽车") {
            response = "🚗 AI自动驾驶技术：\n\n👁️ 环境感知：\n• 摄像头视觉\n• 激光雷达\n• 传感器融合\n\n🧠 决策系统：\n• 路径规划\n• 行为预测\n• 安全控制\n\n🛣️ 技术挑战：\n• 复杂交通环境\n• 极端天气条件\n• 伦理决策\n\n自动驾驶是AI技术的综合应用，代表了AI系统集成的最高水平。"
        } else if lowercasedInput.contains("游戏") || lowercasedInput.contains("娱乐") {
            response = "🎮 AI在游戏开发中的应用：\n\n🤖 游戏AI：\n• NPC行为控制\n• 路径寻找\n• 策略制定\n\n🎲 程序化生成：\n• 关卡设计\n• 地图生成\n• 任务创建\n\n🎯 玩家体验：\n• 难度调整\n• 个性化内容\n• 行为分析\n\nAI让游戏更加智能和有趣，为玩家提供独特的体验。"
        } else if lowercasedInput.contains("大语言模型") || lowercasedInput.contains("gpt") || lowercasedInput.contains("bert") {
            response = "🔤 大语言模型（LLM）技术：\n\n🏗️ 核心架构：\n• Transformer架构\n• 注意力机制\n• 大规模预训练\n\n📚 主要模型：\n• GPT系列：生成式预训练\n• BERT：双向编码器\n• T5：统一文本到文本\n\n💡 应用场景：\n• 文本生成\n• 机器翻译\n• 问答系统\n• 代码生成\n\n大语言模型正在推动AI技术的革命性发展。"
        } else if lowercasedInput.contains("制定学习计划") || lowercasedInput.contains("学习计划") || lowercasedInput.contains("计划") {
            response = "📅 学习计划制定指南：\n\n🎯 第一步：明确学习目标\n• 确定要掌握的具体技能\n• 设定可量化的学习目标\n• 考虑时间限制和优先级\n\n📚 第二步：选择学习路径\n• 机器学习基础：21天入门计划\n• 深度学习专项：28天进阶计划\n• NLP实战：21天应用计划\n• 计算机视觉：24天专业计划\n\n⏰ 第三步：时间管理\n• 每天1-2小时专注学习\n• 周末进行项目实践\n• 定期复习和总结\n\n💡 建议：\n• 使用应用内的学习计划功能\n• 选择适合的模板快速开始\n• 跟踪学习进度和完成情况\n\n你想了解哪个具体领域的学习计划？我可以为你详细介绍！"
        } else if lowercasedInput.contains("安排学习时间") || lowercasedInput.contains("时间管理") || lowercasedInput.contains("时间安排") {
            response = "⏰ 学习时间管理策略：\n\n🌅 早晨时段（30-60分钟）\n• 复习前一天的内容\n• 阅读理论概念\n• 制定当日学习目标\n\n🌞 午间时段（45-90分钟）\n• 实践编程练习\n• 完成小项目\n• 观看教学视频\n\n🌙 晚间时段（60-120分钟）\n• 深入学习新概念\n• 项目实践和调试\n• 总结和记录笔记\n\n📅 每周安排：\n• 周一至周五：理论学习\n• 周六：项目实践\n• 周日：复习和规划\n\n💡 时间管理技巧：\n• 使用番茄工作法（25分钟专注+5分钟休息）\n• 设定明确的时间块\n• 避免多任务并行\n• 定期评估和调整\n\n记住：质量比数量更重要，保持专注和持续性是关键！"
        } else {
            response = "这是一个很有趣的问题！🤔\n\n让我为你提供一些相关的学习建议：\n\n📚 相关概念：\n• 机器学习基础\n• 数据预处理\n• 模型评估\n• 特征工程\n\n💡 学习建议：\n• 从基础概念开始\n• 多做实践项目\n• 参与学习社区\n• 持续关注最新进展\n\n你可以问我更具体的问题，比如特定的算法、工具或者学习路径！\n\n💡 提示：点击💡按钮可以查看预设的学习建议。"
        }
        
        let aiMessage = ChatMessage(
            content: response,
            isUser: false,
            timestamp: Date(),
            messageType: .text
        )
        
        messages.append(aiMessage)
    }
    
    // MARK: - 功能控制
    func clearChat() {
        messages.removeAll()
        let welcomeMessage = ChatMessage(
            content: "聊天记录已清空。有什么可以帮助你的吗？",
            isUser: false,
            timestamp: Date(),
            messageType: .text
        )
        messages.append(welcomeMessage)
    }
    
    func toggleSuggestions() {
        showingSuggestions.toggle()
    }
    
    func toggleLearningPath() {
        showingLearningPath.toggle()
    }
    
    // MARK: - 学习路径生成
    func generateLearningPath(for category: String) -> String {
        // 记录学习路径生成统计
        userProgress?.recordLearningPathGenerated()
        
        switch category.lowercased() {
        case "机器学习":
            return """
            🎯 机器学习学习路径：
            
            📚 第一阶段：基础理论（2-3周）
            • 数学基础：线性代数、微积分、概率统计
            • 编程基础：Python、NumPy、Pandas、Scikit-learn
            
            🚀 第二阶段：核心算法（3-4周）
            • 监督学习：线性回归、逻辑回归、决策树、SVM
            • 无监督学习：聚类、降维、关联规则
            
            🎯 第三阶段：实践应用（2-3周）
            • 数据预处理和特征工程
            • 模型评估和选择
            • 实际项目实践
            
            💡 建议：每天学习1-2小时，理论与实践并重
            """
        case "深度学习":
            return """
            🎯 深度学习学习路径：
            
            📚 第一阶段：理论基础（3-4周）
            • 神经网络基础概念
            • 反向传播算法
            • 激活函数和损失函数
            
            🚀 第二阶段：核心架构（4-5周）
            • CNN：图像处理
            • RNN/LSTM：序列数据
            • Transformer：注意力机制
            
            🎯 第三阶段：框架实践（3-4周）
            • TensorFlow/PyTorch
            • 模型训练和调优
            • 实际项目应用
            
            💡 建议：需要较强的数学基础，建议先掌握机器学习基础
            """
        case "nlp", "自然语言处理":
            return """
            🎯 自然语言处理学习路径：
            
            📚 第一阶段：基础概念（2-3周）
            • 语言学基础
            • 文本预处理技术
            • 词向量和语义表示
            
            🚀 第二阶段：核心任务（3-4周）
            • 文本分类和情感分析
            • 命名实体识别
            • 机器翻译
            
            🎯 第三阶段：现代方法（3-4周）
            • Transformer架构
            • 预训练模型（BERT、GPT）
            • 实际应用项目
            
            💡 建议：结合语言学知识和机器学习技术
            """
        case "计算机视觉":
            return """
            🎯 计算机视觉学习路径：
            
            📚 第一阶段：图像基础（2-3周）
            • 图像处理基础
            • 特征提取方法
            • 传统CV算法
            
            🚀 第二阶段：深度学习（4-5周）
            • CNN架构和原理
            • 图像分类和目标检测
            • 图像分割技术
            
            🎯 第三阶段：高级应用（3-4周）
            • 视频分析
            • 3D视觉
            • 实际项目实践
            
            💡 建议：需要图像处理基础，建议先学习深度学习
            """
        default:
            return """
            🎯 通用AI学习路径：
            
            📚 基础阶段（2-3个月）
            • 数学基础：线性代数、微积分、概率统计
            • 编程技能：Python、数据结构、算法
            • AI概念：机器学习、深度学习基础
            
            🚀 进阶阶段（3-6个月）
            • 专业领域：选择1-2个方向深入学习
            • 项目实践：完成实际项目
            • 工具掌握：相关框架和工具
            
            🎯 高级阶段（6个月+）
            • 前沿技术：关注最新发展
            • 论文阅读：学术研究
            • 社区贡献：开源项目参与
            
            💡 建议：循序渐进，理论与实践结合
            """
        }
    }
}
