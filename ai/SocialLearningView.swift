import SwiftUI

struct SocialLearningView: View {
    @StateObject private var viewModel = SocialLearningViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 自定义分段控制器
                CustomSegmentedControl(selection: $selectedTab)
                    .padding(.horizontal)
                    .padding(.top)
                
                TabView(selection: $selectedTab) {
                    // 学习小组
                    StudyGroupsView(viewModel: viewModel)
                        .tag(0)
                    
                    // 社区动态
                    CommunityFeedView(viewModel: viewModel)
                        .tag(1)
                    
                    // 好友系统
                    FriendsView(viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("社交学习")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showingCreateGroup = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateGroup) {
                CreateGroupView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - 自定义分段控制器
struct CustomSegmentedControl: View {
    @Binding var selection: Int
    private let options = ["学习小组", "社区动态", "好友"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<options.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = index
                    }
                }) {
                    Text(options[index])
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(selection == index ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selection == index ? Color.blue : Color.clear)
                        )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - 学习小组视图
struct StudyGroupsView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.studyGroups) { group in
                    StudyGroupCard(group: group, viewModel: viewModel)
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadStudyGroups()
        }
    }
}

// MARK: - 学习小组卡片
struct StudyGroupCard: View {
    let group: StudyGroup
    @ObservedObject var viewModel: SocialLearningViewModel
    @State private var showingGroupDetail = false
    
    var body: some View {
        Button(action: {
            showingGroupDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(group.members.count)/\(group.maxMembers)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(group.isPublic ? "公开" : "私密")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(group.isPublic ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
                            )
                            .foregroundColor(group.isPublic ? .green : .orange)
                    }
                }
                
                HStack {
                    Text("创建于 \(group.createdAt.formatted(.dateTime.month().day()))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if group.members.contains(viewModel.currentUserId) {
                        Text("已加入")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    } else {
                        Button("加入") {
                            viewModel.joinGroup(group.id)
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingGroupDetail) {
            GroupDetailView(group: group, viewModel: viewModel)
        }
    }
}

// MARK: - 社区动态视图
struct CommunityFeedView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    @State private var showingCreatePost = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.studyPosts) { post in
                    StudyPostCard(post: post, viewModel: viewModel)
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadStudyPosts()
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingCreatePost = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        )
        .sheet(isPresented: $showingCreatePost) {
            CreatePostView(viewModel: viewModel)
        }
    }
}

// MARK: - 学习动态卡片
struct StudyPostCard: View {
    let post: StudyPost
    @ObservedObject var viewModel: SocialLearningViewModel
    @State private var showingComments = false
    
    var body: some View {
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
                .lineLimit(nil)
            
            HStack {
                Button(action: {
                    viewModel.toggleLike(postId: post.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.likes.contains(viewModel.currentUserId) ? "heart.fill" : "heart")
                            .foregroundColor(post.likes.contains(viewModel.currentUserId) ? .red : .gray)
                        Text("\(post.likes.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {
                    showingComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message")
                            .foregroundColor(.gray)
                        Text("\(post.comments.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post, viewModel: viewModel)
        }
    }
}

// MARK: - 好友视图
struct FriendsView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    @State private var showingAddFriend = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.friends) { friend in
                    FriendCard(friend: friend, viewModel: viewModel)
                }
            }
            .padding()
        }
        .refreshable {
            viewModel.loadFriends()
        }
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingAddFriend = true
                    }) {
                        Image(systemName: "person.badge.plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.green)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        )
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView(viewModel: viewModel)
        }
    }
}

// MARK: - 好友卡片
struct FriendCard: View {
    let friend: Friend
    @ObservedObject var viewModel: SocialLearningViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("等级 \(friend.level)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(friend.isOnline ? "在线" : "离线")
                    .font(.caption)
                    .foregroundColor(friend.isOnline ? .green : .gray)
                
                Button("聊天") {
                    viewModel.startChat(with: friend.id)
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SocialLearningView()
}
