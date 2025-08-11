import SwiftUI

struct CourseListView: View {
    @Binding var userProgress: UserProgress
    @StateObject private var courseData = CourseData()
    @State private var selectedCourse: Course?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 欢迎头部
                    welcomeHeader
                    
                    // 课程网格
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(courseData.courses) { course in
                            CourseCardView(
                                course: course,
                                userProgress: userProgress,
                                onTap: {
                                    selectedCourse = course
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("AI学习")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedCourse) { course in
                CourseDetailView(course: course, userProgress: $userProgress)
            }
        }
    }
    
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("欢迎回来！")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("继续你的AI学习之旅")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(userProgress.level)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("等级")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 进度条
            SwiftUI.ProgressView(value: Double(userProgress.totalXP % 100), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            HStack {
                Text("经验值: \(userProgress.totalXP)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("连续学习: \(userProgress.currentStreak) 天")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct CourseCardView: View {
    let course: Course
    let userProgress: UserProgress
    let onTap: () -> Void
    
    private var completedLessonsCount: Int {
        course.lessons.filter { userProgress.completedLessons.contains($0.id) }.count
    }
    
    private var progressPercentage: Double {
        guard !course.lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(course.lessons.count)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 课程图标和难度
                HStack {
                    Image(systemName: course.icon)
                        .font(.title2)
                        .foregroundColor(Color(course.color))
                    
                    Spacer()
                    
                    Text(course.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(course.difficulty.color).opacity(0.2))
                        .foregroundColor(Color(course.difficulty.color))
                        .cornerRadius(8)
                }
                
                // 课程标题和描述
                VStack(alignment: .leading, spacing: 8) {
                    Text(course.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(course.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 进度信息
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("\(completedLessonsCount)/\(course.lessons.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    SwiftUI.ProgressView(value: progressPercentage)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                }
            }
            .padding()
            .frame(height: 180)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CourseListView_Previews: PreviewProvider {
    static var previews: some View {
        CourseListView(userProgress: .constant(UserProgress()))
    }
}
