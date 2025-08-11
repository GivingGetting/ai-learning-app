import SwiftUI

struct CreatePostView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var postContent = ""
    @State private var selectedType: StudyPost.PostType = .insight
    @State private var selectedCourse: UUID?
    @State private var selectedLesson: UUID?
    
    var body: some View {
        NavigationView {
            Form {
                Section("动态内容") {
                    TextField("分享你的学习心得、问题或资源...", text: $postContent, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(5...10)
                }
                
                Section("动态类型") {
                    Picker("类型", selection: $selectedType) {
                        ForEach(StudyPost.PostType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("关联内容") {
                    Text("选择相关的课程或单元（可选）")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 这里可以添加课程和单元选择器
                    Text("课程选择功能待实现")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("预览") {
                    if !postContent.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("预览")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(postContent)
                                .font(.body)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .navigationTitle("发布动态")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("发布") {
                        createPost()
                    }
                    .disabled(postContent.isEmpty)
                }
            }
        }
    }
    
    private func createPost() {
        let newPost = StudyPost(
            authorId: viewModel.currentUserId,
            content: postContent,
            type: selectedType,
            courseId: selectedCourse,
            lessonId: selectedLesson,
            likes: [],
            comments: [],
            createdAt: Date()
        )
        
        viewModel.createPost(newPost)
        dismiss()
    }
}

#Preview {
    CreatePostView(viewModel: SocialLearningViewModel())
}
