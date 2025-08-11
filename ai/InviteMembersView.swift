import SwiftUI

struct InviteMembersView: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [Friend] = []
    @State private var isSearching = false
    @State private var invitedUsers: Set<UUID> = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索用户名或邮箱", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button("清除") {
                            searchText = ""
                            searchResults = []
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                
                Divider()
                
                // 搜索结果
                if isSearching {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("搜索中...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("没有找到用户")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("请检查用户名或邮箱是否正确")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if searchText.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("邀请成员")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("搜索并邀请用户加入你的学习小组")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults) { friend in
                        InviteUserRow(
                            friend: friend,
                            isInvited: invitedUsers.contains(friend.id),
                            onInvite: {
                                inviteUser(friend)
                            }
                        )
                    }
                }
                
                Spacer()
            }
            .navigationTitle("邀请成员")
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
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        
        // 模拟网络搜索延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // 模拟搜索结果
            self.searchResults = self.generateSearchResults()
            self.isSearching = false
        }
    }
    
    private func generateSearchResults() -> [Friend] {
        // 模拟搜索结果
        let sampleNames = ["小明", "小红", "小李", "小王", "小张", "小陈", "小刘"]
        let randomNames = sampleNames.shuffled().prefix(5)
        
        return randomNames.map { name in
            Friend(
                name: name,
                level: Int.random(in: 1...20),
                isOnline: Bool.random(),
                lastActive: Date().addingTimeInterval(-Double.random(in: 0...86400))
            )
        }
    }
    
    private func inviteUser(_ friend: Friend) {
        invitedUsers.insert(friend.id)
        
        // 这里可以实现发送邀请的逻辑
        print("邀请用户 \(friend.name) 加入小组 \(group.name)")
        
        // 显示邀请成功提示
        withAnimation {
            searchResults.removeAll { $0.id == friend.id }
        }
    }
}

struct InviteUserRow: View {
    let friend: Friend
    let isInvited: Bool
    let onInvite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text("等级 \(friend.level)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(friend.isOnline ? "在线" : "离线")
                        .font(.caption)
                        .foregroundColor(friend.isOnline ? .green : .gray)
                }
            }
            
            Spacer()
            
            if isInvited {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("已邀请")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                Button("邀请") {
                    onInvite()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 4)
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
    
    InviteMembersView(
        group: sampleGroup,
        viewModel: SocialLearningViewModel()
    )
}
