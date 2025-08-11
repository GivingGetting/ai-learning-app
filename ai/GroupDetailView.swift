import SwiftUI

struct GroupDetailView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditGroup = false
    @State private var showingInviteMembers = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 小组信息卡片
                    GroupInfoCard(group: group, viewModel: viewModel)
                    
                    // 成员列表
                    MembersSection(group: group, viewModel: viewModel)
                    
                    // 小组动态
                    GroupPostsSection(group: group, viewModel: viewModel)
                }
                .padding()
            }
            .navigationTitle(group.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if group.admins.contains(viewModel.currentUserId) {
                            Button("编辑小组") {
                                showingEditGroup = true
                            }
                            
                            Button("邀请成员") {
                                showingInviteMembers = true
                            }
                        }
                        
                        if group.members.contains(viewModel.currentUserId) {
                            Button("退出小组", role: .destructive) {
                                leaveGroup()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditGroup) {
                EditGroupView(group: group, viewModel: viewModel)
            }
            .sheet(isPresented: $showingInviteMembers) {
                InviteMembersView(group: group, viewModel: viewModel)
            }
        }
    }
    
    private func leaveGroup() {
        viewModel.leaveGroup(group.id)
        dismiss()
    }
}

// MARK: - 小组信息卡片
struct GroupInfoCard: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(group.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(group.isPublic ? "公开" : "私密")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(group.isPublic ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                        )
                        .foregroundColor(group.isPublic ? .green : .orange)
                    
                    Text("\(group.members.count)/\(group.maxMembers)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(group.members.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("成员")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(group.courses.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("课程")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text(group.createdAt.formatted(.dateTime.month().day()))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("创建时间")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            if group.members.contains(viewModel.currentUserId) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    
                    Text("你已加入此小组")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - 成员列表
struct MembersSection: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("成员 (\(group.members.count))")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(group.members, id: \.self) { memberId in
                    MemberCard(
                        memberId: memberId,
                        isAdmin: group.admins.contains(memberId),
                        isCurrentUser: memberId == viewModel.currentUserId
                    )
                }
            }
        }
    }
}

struct MemberCard: View {
    let memberId: UUID
    let isAdmin: Bool
    let isCurrentUser: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                if isAdmin {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                        }
                        Spacer()
                    }
                }
            }
            
            VStack(spacing: 2) {
                Text(isCurrentUser ? "我" : "用户 \(memberId.uuidString.prefix(6))")
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if isAdmin {
                    Text("管理员")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(height: 80)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - 小组动态
struct GroupPostsSection: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("小组动态")
                    .font(.headline)
                
                Spacer()
                
                Button("发布动态") {
                    // 这里可以实现发布小组动态的功能
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Text("小组动态功能待实现")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
}

#Preview {
    let sampleGroup = StudyGroup(
        name: "AI初学者联盟",
        description: "欢迎所有AI初学者加入！我们一起学习，一起进步，分享学习心得和资源。",
        members: [UUID(), UUID(), UUID()],
        admins: [UUID()],
        courses: [],
        createdAt: Date().addingTimeInterval(-86400 * 7),
        isPublic: true,
        maxMembers: 50
    )
    
    GroupDetailView(
        group: sampleGroup,
        viewModel: SocialLearningViewModel()
    )
}
