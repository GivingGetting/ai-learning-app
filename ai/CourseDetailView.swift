import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @Binding var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLesson: Lesson?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 课程头部信息
                    courseHeader
                    
                    // 课程单元列表
                    VStack(spacing: 16) {
                        ForEach(Array(course.lessons.enumerated()), id: \.element.id) { index, lesson in
                            LessonRowView(
                                lesson: lesson,
                                index: index + 1,
                                isCompleted: userProgress.completedLessons.contains(lesson.id),
                                onTap: {
                                    selectedLesson = lesson
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(course.title)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(item: $selectedLesson) { lesson in
                LessonView(lesson: lesson, userProgress: $userProgress)
            }
        }
    }
    
    private var courseHeader: some View {
        VStack(spacing: 16) {
            // 课程图标和难度
            HStack {
                Image(systemName: course.icon)
                    .font(.system(size: 40))
                    .foregroundColor(Color(course.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(course.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(course.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(course.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(course.difficulty.color).opacity(0.2))
                        .foregroundColor(Color(course.difficulty.color))
                        .cornerRadius(12)
                    
                    Text("\(course.lessons.count) 个单元")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 课程进度
            let completedCount = course.lessons.filter { userProgress.completedLessons.contains($0.id) }.count
            let progressPercentage = course.lessons.isEmpty ? 0 : Double(completedCount) / Double(course.lessons.count)
            
            VStack(spacing: 8) {
                HStack {
                    Text("课程进度")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(completedCount)/\(course.lessons.count)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                SwiftUI.ProgressView(value: progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct LessonRowView: View {
    let lesson: Lesson
    let index: Int
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 单元编号和状态
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(index)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                // 单元信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(lesson.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(lesson.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                        
                        Text("\(lesson.questions.count) 个问题")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CourseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCourse = Course(
            title: "AI基础入门",
            description: "了解人工智能的基本概念和发展历史",
            difficulty: .beginner,
            lessons: [],
            icon: "brain.head.profile",
            color: "blue"
        )
        
        CourseDetailView(course: sampleCourse, userProgress: .constant(UserProgress()))
    }
}
