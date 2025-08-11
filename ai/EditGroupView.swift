import SwiftUI

struct EditGroupView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var groupName: String
    @State private var groupDescription: String
    @State private var isPublic: Bool
    @State private var maxMembers: Int
    
    init(group: StudyGroup, viewModel: SocialLearningViewModel) {
        self.group = group
        self.viewModel = viewModel
        self._groupName = State(initialValue: group.name)
        self._groupDescription = State(initialValue: group.description)
        self._isPublic = State(initialValue: group.isPublic)
        self._maxMembers = State(initialValue: group.maxMembers)
    }
    
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
                
                Section("危险操作") {
                    Button("删除小组") {
                        deleteGroup()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("编辑小组")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveChanges()
                    }
                    .disabled(groupName.isEmpty || groupDescription.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedGroup = group
        updatedGroup.name = groupName
        updatedGroup.description = groupDescription
        updatedGroup.isPublic = isPublic
        updatedGroup.maxMembers = maxMembers
        
        viewModel.updateGroup(updatedGroup)
        dismiss()
    }
    
    private func deleteGroup() {
        viewModel.deleteGroup(group.id)
        dismiss()
    }
}

#Preview {
    let sampleGroup = StudyGroup(
        name: "AI初学者联盟",
        description: "欢迎所有AI初学者加入！",
        members: [UUID()],
        admins: [UUID()],
        courses: [],
        createdAt: Date(),
        isPublic: true,
        maxMembers: 50
    )
    
    EditGroupView(
        group: sampleGroup,
        viewModel: SocialLearningViewModel()
    )
}
