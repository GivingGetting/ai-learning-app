import SwiftUI

struct ProgressView: View {
    @Binding var userProgress: UserProgress
    @StateObject private var courseData = CourseData()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 总体进度概览
                    overallProgressSection
                    
                    // 课程完成情况
                    courseProgressSection
                    
                    // 学习统计
                    learningStatsSection
                    
                    // 成就展示
                    achievementsSection
                }
                .padding(.vertical)
            }
            .navigationTitle("学习进度")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var overallProgressSection: some View {
        VStack(spacing: 20) {
            // 等级和经验值
            HStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("\(userProgress.level)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("当前等级")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(userProgress.totalXP)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.orange)
                    
                    Text("总经验值")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("\(userProgress.currentStreak)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("连续学习")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // 升级进度
            let currentLevelXP = userProgress.totalXP % 100
            let nextLevelXP = 100 - currentLevelXP
            
            VStack(spacing: 8) {
                HStack {
                    Text("距离下一级还需: \(nextLevelXP) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(currentLevelXP)/100")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                SwiftUI.ProgressView(value: Double(currentLevelXP), total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var courseProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("课程完成情况")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(courseData.courses) { course in
                    CourseProgressRow(
                        course: course,
                        userProgress: userProgress
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var learningStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(
                    title: "学习天数",
                    value: "\(userProgress.getStudyStreak())",
                    icon: "calendar",
                    color: .blue
                )
                
                StatCard(
                    title: "本周学习时间",
                    value: "\(userProgress.getWeeklyStudyTime()) 分钟",
                    icon: "clock",
                    color: .green
                )
                
                StatCard(
                    title: "平均每日XP",
                    value: "\(userProgress.totalXP / max(1, userProgress.getStudyStreak()))",
                    icon: "chart.bar.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "完成率",
                    value: "\(Int(Double(userProgress.completedLessons.count) / Double(courseData.courses.flatMap { $0.lessons }.count) * 100))%",
                    icon: "checkmark.circle.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("成就徽章")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if userProgress.achievements.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "trophy")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("还没有获得成就")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("继续学习，解锁更多成就！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(userProgress.achievements) { achievement in
                        AchievementCard(achievement: achievement)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - 计算函数
    private func calculateTotalLearningDays() -> Int {
        // 简化计算，基于经验值估算
        return max(1, userProgress.totalXP / 10)
    }
    
    private func calculateAverageDailyXP() -> Int {
        let totalDays = calculateTotalLearningDays()
        return totalDays > 0 ? userProgress.totalXP / totalDays : 0
    }
    
    private func calculateLearningEfficiency() -> Int {
        let totalLessons = courseData.courses.reduce(0) { $0 + $1.lessons.count }
        guard totalLessons > 0 else { return 0 }
        return Int((Double(userProgress.completedLessons.count) / Double(totalLessons)) * 100)
    }
}

struct CourseProgressRow: View {
    let course: Course
    let userProgress: UserProgress
    
    private var completedLessonsCount: Int {
        course.lessons.filter { userProgress.completedLessons.contains($0.id) }.count
    }
    
    private var progressPercentage: Double {
        guard !course.lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(course.lessons.count)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 课程图标
            Image(systemName: course.icon)
                .font(.title2)
                .foregroundColor(Color(course.color))
                .frame(width: 40)
            
            // 课程信息
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("\(completedLessonsCount)/\(course.lessons.count) 单元完成")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 进度百分比
            Text("\(Int(progressPercentage * 100))%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(userProgress: .constant(UserProgress()))
    }
}
