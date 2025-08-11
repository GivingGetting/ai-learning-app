import Foundation
import UserNotifications

// MARK: - 课程模型
struct Course: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: Difficulty
    let lessons: [Lesson]
    let icon: String
    let color: String
    
    init(title: String, description: String, difficulty: Difficulty, lessons: [Lesson], icon: String, color: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.lessons = lessons
        self.icon = icon
        self.color = color
    }
    
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
    let id: UUID
    let title: String
    let content: String
    let type: LessonType
    let questions: [Question]
    var isCompleted: Bool
    
    init(title: String, content: String, type: LessonType, questions: [Question], isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.type = type
        self.questions = questions
        self.isCompleted = isCompleted
    }
    
    enum LessonType: String, CaseIterable, Codable {
        case theory = "理论"
        case practice = "实践"
        case quiz = "测验"
    }
}

// MARK: - 问题模型
struct Question: Identifiable, Codable {
    let id: UUID
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let type: QuestionType
    
    init(question: String, options: [String], correctAnswer: Int, explanation: String, type: QuestionType) {
        self.id = UUID()
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.type = type
    }
    
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
    
    enum CodingKeys: String, CodingKey {
        case completedLessons, currentStreak, totalXP, level, achievements, dailyReminderEnabled, reminderTime, lastStudyDate
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
    }
    
    func completeLesson(_ lessonId: UUID) {
        completedLessons.insert(lessonId)
        totalXP += 10
        currentStreak += 1
        lastStudyDate = Date()
        checkLevelUp()
        saveProgress()
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
    let id: UUID
    let title: String
    let description: String
    let icon: String
    let dateEarned: Date
    
    init(title: String, description: String, icon: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.icon = icon
        self.dateEarned = Date()
    }
}

// MARK: - AI聊天助手模型
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let messageType: MessageType
    
    init(content: String, isUser: Bool, messageType: MessageType = .text) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
        self.messageType = messageType
    }
    
    enum MessageType: String, Codable {
        case text = "文本"
        case image = "图片"
        case code = "代码"
        case link = "链接"
    }
}

struct ChatSession: Identifiable, Codable {
    let id: UUID
    let title: String
    let messages: [ChatMessage]
    let createdAt: Date
    let lastUpdated: Date
    let topic: ChatTopic
    
    init(title: String, messages: [ChatMessage] = [], topic: ChatTopic) {
        self.id = UUID()
        self.title = title
        self.messages = messages
        self.createdAt = Date()
        self.lastUpdated = Date()
        self.topic = topic
    }
    
    enum ChatTopic: String, CaseIterable, Codable {
        case general = "通用AI"
        case machineLearning = "机器学习"
        case deepLearning = "深度学习"
        case nlp = "自然语言处理"
        case computerVision = "计算机视觉"
        case reinforcementLearning = "强化学习"
        case generativeAI = "生成式AI"
        case aiTools = "AI工具"
        case aiBusiness = "AI商业"
        case custom = "自定义话题"
    }
}

// MARK: - 学习计划模型
struct StudyPlan: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let targetDate: Date
    let dailyGoal: Int // 每日学习目标（分钟）
    let weeklyGoal: Int // 每周学习目标（分钟）
    let courses: [UUID] // 关联的课程ID
    let isActive: Bool
    let createdAt: Date
    let progress: StudyPlanProgress
    
    init(title: String, description: String, targetDate: Date, dailyGoal: Int, weeklyGoal: Int, courses: [UUID], isActive: Bool, createdAt: Date, progress: StudyPlanProgress) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetDate = targetDate
        self.dailyGoal = dailyGoal
        self.weeklyGoal = weeklyGoal
        self.courses = courses
        self.isActive = isActive
        self.createdAt = createdAt
        self.progress = progress
    }
}

struct StudyPlanProgress: Codable {
    var totalMinutes: Int = 0
    var dailyStreak: Int = 0
    var weeklyMinutes: [Int] = Array(repeating: 0, count: 7)
    var completedLessons: Int = 0
    var targetLessons: Int = 0
}

// MARK: - 社交学习模型
struct StudyGroup: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let members: [UUID] // 成员用户ID
    let admins: [UUID] // 管理员用户ID
    let courses: [UUID] // 关联的课程ID
    let createdAt: Date
    let isPublic: Bool
    let maxMembers: Int
    
    init(name: String, description: String, members: [UUID] = [], admins: [UUID] = [], courses: [UUID] = [], isPublic: Bool = true, maxMembers: Int = 50) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.members = members
        self.admins = admins
        self.courses = courses
        self.createdAt = Date()
        self.isPublic = isPublic
        self.maxMembers = maxMembers
    }
}

struct StudyPost: Identifiable, Codable {
    let id: UUID
    let authorId: UUID
    let content: String
    let type: PostType
    let courseId: UUID?
    let lessonId: UUID?
    let likes: [UUID] // 点赞用户ID
    let comments: [StudyComment]
    let createdAt: Date
    
    init(authorId: UUID, content: String, type: PostType, courseId: UUID? = nil, lessonId: UUID? = nil, likes: [UUID] = [], comments: [StudyComment] = []) {
        self.id = UUID()
        self.authorId = authorId
        self.content = content
        self.type = type
        self.courseId = courseId
        self.lessonId = lessonId
        self.likes = likes
        self.comments = comments
        self.createdAt = Date()
    }
    
    enum PostType: String, Codable {
        case question = "问题"
        case insight = "心得"
        case resource = "资源分享"
        case achievement = "成就分享"
    }
}

struct StudyComment: Identifiable, Codable {
    let id: UUID
    let authorId: UUID
    let content: String
    let createdAt: Date
    let likes: [UUID]
    
    init(authorId: UUID, content: String, likes: [UUID] = []) {
        self.id = UUID()
        self.authorId = authorId
        self.content = content
        self.createdAt = Date()
        self.likes = likes
    }
}

// MARK: - 云端同步模型
struct SyncData: Codable {
    let userId: String
    let lastSyncTime: Date
    let userProgress: UserProgress
    let studyPlans: [StudyPlan]
    let chatSessions: [ChatSession]
    let studyGroups: [StudyGroup]
    let studyPosts: [StudyPost]
}
