import Foundation
import SwiftUI

class SocialLearningViewModel: ObservableObject {
    @Published var studyGroups: [StudyGroup] = []
    @Published var studyPosts: [StudyPost] = []
    @Published var friends: [Friend] = []
    @Published var showingCreateGroup = false
    @Published var isLoading = false
    
    let currentUserId = UUID() // 当前用户ID，实际应用中应该从用户系统获取
    
    init() {
        loadData()
    }
    
    // MARK: - 数据加载
    func loadData() {
        loadStudyGroups()
        loadStudyPosts()
        loadFriends()
    }
    
    func loadStudyGroups() {
        isLoading = true
        
        // 模拟网络请求延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.studyGroups = self.generateSampleGroups()
            self.isLoading = false
        }
    }
    
    func loadStudyPosts() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.studyPosts = self.generateSamplePosts()
            self.isLoading = false
        }
    }
    
    func loadFriends() {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.friends = self.generateSampleFriends()
            self.isLoading = false
        }
    }
    
    // MARK: - 学习小组管理
    func createStudyGroup(_ group: StudyGroup) {
        studyGroups.append(group)
        saveStudyGroups()
    }
    
    func joinGroup(_ groupId: UUID) {
        if let index = studyGroups.firstIndex(where: { $0.id == groupId }) {
            studyGroups[index].members.append(currentUserId)
            saveStudyGroups()
        }
    }
    
    func leaveGroup(_ groupId: UUID) {
        if let index = studyGroups.firstIndex(where: { $0.id == groupId }) {
            studyGroups[index].members.removeAll { $0 == currentUserId }
            saveStudyGroups()
        }
    }
    
    func updateGroup(_ group: StudyGroup) {
        if let index = studyGroups.firstIndex(where: { $0.id == group.id }) {
            studyGroups[index] = group
            saveStudyGroups()
        }
    }
    
    func deleteGroup(_ groupId: UUID) {
        studyGroups.removeAll { $0.id == groupId }
        saveStudyGroups()
    }
    
    // MARK: - 社区动态管理
    func createPost(_ post: StudyPost) {
        studyPosts.insert(post, at: 0)
        saveStudyPosts()
    }
    
    func toggleLike(postId: UUID) {
        if let index = studyPosts.firstIndex(where: { $0.id == postId }) {
            if studyPosts[index].likes.contains(currentUserId) {
                studyPosts[index].likes.removeAll { $0 == currentUserId }
            } else {
                studyPosts[index].likes.append(currentUserId)
            }
            saveStudyPosts()
        }
    }
    
    func addComment(to postId: UUID, comment: StudyComment) {
        if let index = studyPosts.firstIndex(where: { $0.id == postId }) {
            studyPosts[index].comments.append(comment)
            saveStudyPosts()
        }
    }
    
    func deletePost(_ postId: UUID) {
        studyPosts.removeAll { $0.id == postId }
        saveStudyPosts()
    }
    
    // MARK: - 好友系统管理
    func addFriend(_ friend: Friend) {
        friends.append(friend)
        saveFriends()
    }
    
    func removeFriend(_ friendId: UUID) {
        friends.removeAll { $0.id == friendId }
        saveFriends()
    }
    
    func startChat(with friendId: UUID) {
        // 这里可以实现启动聊天的逻辑
        print("启动与好友 \(friendId) 的聊天")
    }
    
    // MARK: - 数据持久化
    private func saveStudyGroups() {
        if let encoded = try? JSONEncoder().encode(studyGroups) {
            UserDefaults.standard.set(encoded, forKey: "StudyGroups")
        }
    }
    
    private func saveStudyPosts() {
        if let encoded = try? JSONEncoder().encode(studyPosts) {
            UserDefaults.standard.set(encoded, forKey: "StudyPosts")
        }
    }
    
    private func saveFriends() {
        if let encoded = try? JSONEncoder().encode(friends) {
            UserDefaults.standard.set(encoded, forKey: "Friends")
        }
    }
    
    // MARK: - 示例数据生成
    private func generateSampleGroups() -> [StudyGroup] {
        return [
            StudyGroup(
                name: "AI初学者联盟",
                description: "欢迎所有AI初学者加入！我们一起学习，一起进步，分享学习心得和资源。",
                members: [currentUserId, UUID(), UUID()],
                admins: [currentUserId],
                courses: [],
                createdAt: Date().addingTimeInterval(-86400 * 7),
                isPublic: true,
                maxMembers: 50
            ),
            StudyGroup(
                name: "机器学习进阶",
                description: "专注于机器学习算法和实践，适合有一定基础的学习者。",
                members: [UUID(), UUID(), UUID()],
                admins: [UUID()],
                courses: [],
                createdAt: Date().addingTimeInterval(-86400 * 14),
                isPublic: true,
                maxMembers: 30
            ),
            StudyGroup(
                name: "深度学习研究组",
                description: "深入研究深度学习理论和应用，包括神经网络、CNN、RNN等。",
                members: [UUID(), UUID()],
                admins: [UUID()],
                courses: [],
                createdAt: Date().addingTimeInterval(-86400 * 21),
                isPublic: false,
                maxMembers: 20
            ),
            StudyGroup(
                name: "NLP爱好者",
                description: "自然语言处理技术交流，分享最新的NLP研究成果和应用案例。",
                members: [UUID(), UUID(), UUID(), UUID()],
                admins: [UUID()],
                courses: [],
                createdAt: Date().addingTimeInterval(-86400 * 5),
                isPublic: true,
                maxMembers: 40
            )
        ]
    }
    
    private func generateSamplePosts() -> [StudyPost] {
        return [
            StudyPost(
                authorId: UUID(),
                content: "今天完成了机器学习基础课程，感觉对监督学习有了更深的理解。特别是线性回归和逻辑回归的区别，现在终于搞清楚了！",
                type: .insight,
                courseId: nil,
                lessonId: nil,
                likes: [currentUserId, UUID()],
                comments: [
                    StudyComment(
                        authorId: UUID(),
                        content: "恭喜！我也在学习这部分，有什么好的学习方法可以分享吗？",
                        createdAt: Date().addingTimeInterval(-3600),
                        likes: []
                    )
                ],
                createdAt: Date().addingTimeInterval(-3600)
            ),
            StudyPost(
                authorId: UUID(),
                content: "有人能解释一下梯度下降算法吗？我在理解这个概念时遇到了一些困难。",
                type: .question,
                courseId: nil,
                lessonId: nil,
                likes: [],
                comments: [
                    StudyComment(
                        authorId: UUID(),
                        content: "梯度下降就像是下山找最低点，每次沿着最陡峭的方向走一小步。",
                        createdAt: Date().addingTimeInterval(-7200),
                        likes: [currentUserId]
                    ),
                    StudyComment(
                        authorId: UUID(),
                        content: "建议看看吴恩达的课程视频，讲得很清楚！",
                        createdAt: Date().addingTimeInterval(-5400),
                        likes: []
                    )
                ],
                createdAt: Date().addingTimeInterval(-7200)
            ),
            StudyPost(
                authorId: UUID(),
                content: "分享一个很好的AI学习资源网站：https://example.com，里面有大量的教程和实战项目。",
                type: .resource,
                courseId: nil,
                lessonId: nil,
                likes: [currentUserId, UUID(), UUID()],
                comments: [],
                createdAt: Date().addingTimeInterval(-10800)
            ),
            StudyPost(
                authorId: currentUserId,
                content: "终于升级到5级了！感谢这个学习平台，让我能够系统地学习AI知识。",
                type: .achievement,
                courseId: nil,
                lessonId: nil,
                likes: [UUID(), UUID(), UUID()],
                comments: [
                    StudyComment(
                        authorId: UUID(),
                        content: "恭喜恭喜！我也要加油了！",
                        createdAt: Date().addingTimeInterval(-1800),
                        likes: []
                    )
                ],
                createdAt: Date().addingTimeInterval(-1800)
            )
        ]
    }
    
    private func generateSampleFriends() -> [Friend] {
        return [
            Friend(
                name: "张三",
                level: 8,
                isOnline: true,
                lastActive: Date()
            ),
            Friend(
                name: "李四",
                level: 5,
                isOnline: false,
                lastActive: Date().addingTimeInterval(-3600)
            ),
            Friend(
                name: "王五",
                level: 12,
                isOnline: true,
                lastActive: Date()
            ),
            Friend(
                name: "赵六",
                level: 3,
                isOnline: false,
                lastActive: Date().addingTimeInterval(-7200)
            )
        ]
    }
}

// MARK: - 好友模型
struct Friend: Identifiable, Codable {
    let id = UUID()
    let name: String
    let level: Int
    let isOnline: Bool
    let lastActive: Date
}
