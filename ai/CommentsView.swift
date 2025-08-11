import SwiftUI

struct CommentsView: View {
    let post: StudyPost
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newComment = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 原帖内容
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("用户 \(post.authorId.uuidString.prefix(8))")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(post.createdAt.formatted(.relative(presentation: .named)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(post.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Text(post.content)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text("\(post.likes.count) 赞")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(post.comments.count) 评论")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                Divider()
                
                // 评论列表
                if post.comments.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("还没有评论")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("成为第一个评论的人吧！")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(post.comments) { comment in
                                CommentRow(comment: comment)
                            }
                        }
                        .padding()
                    }
                }
                
                Divider()
                
                // 添加评论
                HStack(spacing: 12) {
                    TextField("添加评论...", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("发送") {
                        addComment()
                    }
                    .disabled(newComment.isEmpty)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addComment() {
        let comment = StudyComment(
            authorId: viewModel.currentUserId,
            content: newComment,
            createdAt: Date(),
            likes: []
        )
        
        viewModel.addComment(to: post.id, comment: comment)
        newComment = ""
    }
}

struct CommentRow: View {
    let comment: StudyComment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title3)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("用户 \(comment.authorId.uuidString.prefix(8))")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(comment.createdAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(comment.content)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack {
                    Button(action: {
                        // 点赞功能待实现
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart")
                                .font(.caption)
                            Text("\(comment.likes.count)")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    let samplePost = StudyPost(
        authorId: UUID(),
        content: "这是一个示例帖子内容",
        type: .insight,
        courseId: nil,
        lessonId: nil,
        likes: [],
        comments: [
            StudyComment(
                authorId: UUID(),
                content: "这是一个示例评论",
                createdAt: Date(),
                likes: []
            )
        ],
        createdAt: Date()
    )
    
    CommentsView(
        post: samplePost,
        viewModel: SocialLearningViewModel()
    )
}
