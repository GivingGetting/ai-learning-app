import Foundation
import UserNotifications

// MARK: - 课程模型
struct Course: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let difficulty: Difficulty
    let lessons: [Lesson]
    let icon: String
    let color: String
    
    enum Difficulty: String, CaseIterable, Codable {
        case beginner = "初级"
        case intermediate = "中级"
        case advanced = "高级"
        
        var color: String {
            switch self {
            case .beginner: return "green"
            case .intermediate: return "orange"
            case .advanced: return "red"
            }
        }
    }
}

// MARK: - 课程单元模型
struct Lesson: Identifiable, Codable {
    let id = UUID()
    let title: String
    let content: String
    let type: LessonType
    let questions: [Question]
    var isCompleted: Bool
    
    enum LessonType: String, CaseIterable, Codable {
        case theory = "理论"
        case practice = "实践"
        case quiz = "测验"
    }
}

// MARK: - 问题模型
struct Question: Identifiable, Codable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let type: QuestionType
    
    enum QuestionType: String, CaseIterable, Codable {
        case multipleChoice = "选择题"
        case trueFalse = "判断题"
        case fillBlank = "填空题"
    }
}

// MARK: - 用户进度模型
class UserProgress: ObservableObject, Codable {
    @Published var completedLessons: Set<UUID> = []
    @Published var currentStreak: Int = 0
    @Published var totalXP: Int = 0
    @Published var level: Int = 1
    @Published var achievements: [Achievement] = []
    @Published var dailyReminderEnabled: Bool = false
    @Published var reminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @Published var lastStudyDate: Date = Date()
    
    // AI聊天相关数据
    @Published var aiChatCount: Int = 0
    @Published var aiQuestionsAsked: Int = 0
    @Published var aiLearningPathsGenerated: Int = 0
    @Published var lastAIChatDate: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case completedLessons, currentStreak, totalXP, level, achievements, dailyReminderEnabled, reminderTime, lastStudyDate, aiChatCount, aiQuestionsAsked, aiLearningPathsGenerated, lastAIChatDate
    }
    
    init() {
        loadProgress()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        completedLessons = try container.decode(Set<UUID>.self, forKey: .completedLessons)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        totalXP = try container.decode(Int.self, forKey: .totalXP)
        level = try container.decode(Int.self, forKey: .level)
        achievements = try container.decode([Achievement].self, forKey: .achievements)
        dailyReminderEnabled = try container.decode(Bool.self, forKey: .dailyReminderEnabled)
        reminderTime = try container.decode(Date.self, forKey: .reminderTime)
        lastStudyDate = try container.decode(Date.self, forKey: .lastStudyDate)
        
        // AI聊天相关数据
        aiChatCount = try container.decode(Int.self, forKey: .aiChatCount)
        aiQuestionsAsked = try container.decode(Int.self, forKey: .aiQuestionsAsked)
        aiLearningPathsGenerated = try container.decode(Int.self, forKey: .aiLearningPathsGenerated)
        lastAIChatDate = try container.decode(Date.self, forKey: .lastAIChatDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(completedLessons, forKey: .completedLessons)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(totalXP, forKey: .totalXP)
        try container.encode(level, forKey: .level)
        try container.encode(achievements, forKey: .achievements)
        try container.encode(dailyReminderEnabled, forKey: .dailyReminderEnabled)
        try container.encode(reminderTime, forKey: .reminderTime)
        try container.encode(lastStudyDate, forKey: .lastStudyDate)
        
        // AI聊天相关数据
        try container.encode(aiChatCount, forKey: .aiChatCount)
        try container.encode(aiQuestionsAsked, forKey: .aiQuestionsAsked)
        try container.encode(aiLearningPathsGenerated, forKey: .aiLearningPathsGenerated)
        try container.encode(lastAIChatDate, forKey: .lastAIChatDate)
    }
    
    func completeLesson(_ lessonId: UUID) {
        completedLessons.insert(lessonId)
        totalXP += 10
        currentStreak += 1
        lastStudyDate = Date()
        checkLevelUp()
        saveProgress()
    }
    
    // MARK: - AI聊天相关方法
    func recordAIChat() {
        aiChatCount += 1
        aiQuestionsAsked += 1
        lastAIChatDate = Date()
        totalXP += 2 // AI聊天获得少量经验值
        checkLevelUp()
        saveProgress()
    }
    
    func recordLearningPathGenerated() {
        aiLearningPathsGenerated += 1
        totalXP += 5 // 生成学习路径获得更多经验值
        checkLevelUp()
        saveProgress()
    }
    
    func getAIChatStats() -> (totalChats: Int, questionsAsked: Int, pathsGenerated: Int, lastChatDate: Date) {
        return (aiChatCount, aiQuestionsAsked, aiLearningPathsGenerated, lastAIChatDate)
    }
    
    func getStudyStreak() -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        while true {
            if calendar.isDate(currentDate, inSameDayAs: lastStudyDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getWeeklyStudyTime() -> Int {
        // 这里可以添加更复杂的学习时间统计逻辑
        return completedLessons.count * 15 // 假设每个课程单元需要15分钟
    }
    
    func scheduleDailyReminder() {
        guard dailyReminderEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "AI学习提醒"
        content.body = "今天还没有学习AI知识哦，快来继续你的学习之旅吧！"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("设置通知失败: \(error)")
            }
        }
    }
    
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }
    
    private func checkLevelUp() {
        let newLevel = (totalXP / 100) + 1
        if newLevel > level {
            level = newLevel
            achievements.append(Achievement(title: "升级到 \(level) 级", description: "恭喜你升级了！", icon: "star.fill"))
        }
    }
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserProgress")
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "UserProgress"),
           let decoded = try? JSONDecoder().decode(UserProgress.self, from: data) {
            completedLessons = decoded.completedLessons
            currentStreak = decoded.currentStreak
            totalXP = decoded.totalXP
            level = decoded.level
            achievements = decoded.achievements
            dailyReminderEnabled = decoded.dailyReminderEnabled
            reminderTime = decoded.reminderTime
            lastStudyDate = decoded.lastStudyDate
        }
    }
}

// MARK: - 成就模型
struct Achievement: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let dateEarned: Date
    
    init(title: String, description: String, icon: String) {
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = Date()
    }
}

// MARK: - 学习小组模型
struct StudyGroup: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var members: [UUID]
    var admins: [UUID]
    var courses: [UUID]
    var createdAt: Date
    var isPublic: Bool
    var maxMembers: Int
    
    init(name: String, description: String, members: [UUID], admins: [UUID], courses: [UUID], createdAt: Date, isPublic: Bool, maxMembers: Int) {
        self.name = name
        self.description = description
        self.members = members
        self.admins = admins
        self.courses = courses
        self.createdAt = createdAt
        self.isPublic = isPublic
        self.maxMembers = maxMembers
    }
}

// MARK: - 社区动态模型
struct StudyPost: Identifiable, Codable {
    let id = UUID()
    var authorId: UUID
    var content: String
    var type: PostType
    var courseId: UUID?
    var lessonId: UUID?
    var likes: [UUID]
    var comments: [StudyComment]
    var createdAt: Date
    
    enum PostType: String, CaseIterable, Codable {
        case insight = "学习心得"
        case question = "问题讨论"
        case resource = "资源分享"
        case achievement = "成就分享"
    }
}

// MARK: - 评论模型
struct StudyComment: Identifiable, Codable {
    let id = UUID()
    var authorId: UUID
    var content: String
    var createdAt: Date
    var likes: [UUID]
}

// MARK: - AI聊天会话模型
struct ChatSession: Identifiable, Codable {
    let id = UUID()
    var title: String
    var messages: [ChatMessage]
    var createdAt: Date
    var lastMessageTime: Date
    var isArchived: Bool
    
    init(title: String) {
        self.title = title
        self.messages = []
        self.createdAt = Date()
        self.lastMessageTime = Date()
        self.isArchived = false
    }
}

// MARK: - AI聊天消息模型
struct ChatMessage: Identifiable, Codable {
    let id = UUID()
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var messageType: MessageType
    
    enum MessageType: String, Codable {
        case text
        case image
        case code
        case suggestion
    }
}

// MARK: - 同步数据模型
struct SyncData: Codable {
    let userId: String
    let lastSyncTime: Date
    let userProgress: UserProgress
    let studyPlans: [StudyPlan]
    let chatSessions: [ChatSession]
    let studyGroups: [StudyGroup]
    let studyPosts: [StudyPost]
    
    init(userId: String, lastSyncTime: Date, userProgress: UserProgress, studyPlans: [StudyPlan], chatSessions: [ChatSession], studyGroups: [StudyGroup], studyPosts: [StudyPost]) {
        self.userId = userId
        self.lastSyncTime = lastSyncTime
        self.userProgress = userProgress
        self.studyPlans = studyPlans
        self.chatSessions = chatSessions
        self.studyGroups = studyGroups
        self.studyPosts = studyPosts
    }
}
