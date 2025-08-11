import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isPublic = true
    @State private var maxMembers = 30
    @State private var selectedCourses: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本信息") {
                    TextField("小组名称", text: $groupName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("小组描述", text: $groupDescription, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section("设置") {
                    Toggle("公开小组", isOn: $isPublic)
                    
                    Stepper("最大成员数: \(maxMembers)", value: $maxMembers, in: 5...100, step: 5)
                }
                
                Section("关联课程") {
                    Text("选择与小组相关的AI课程")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // 这里可以添加课程选择器
                    Text("课程选择功能待实现")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("创建学习小组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("创建") {
                        createGroup()
                    }
                    .disabled(groupName.isEmpty || groupDescription.isEmpty)
                }
            }
        }
    }
    
    private func createGroup() {
        let newGroup = StudyGroup(
            name: groupName,
            description: groupDescription,
            members: [viewModel.currentUserId],
            admins: [viewModel.currentUserId],
            courses: Array(selectedCourses),
            createdAt: Date(),
            isPublic: isPublic,
            maxMembers: maxMembers
        )
        
        viewModel.createStudyGroup(newGroup)
        dismiss()
    }
}

#Preview {
    CreateGroupView(viewModel: SocialLearningViewModel())
}
