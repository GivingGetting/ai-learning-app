import SwiftUI

struct AddFriendView: View {
    @ObservedObject var viewModel: SocialLearningViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [Friend] = []
    @State private var isSearching = false
    
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
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("搜索好友")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("输入用户名或邮箱来查找并添加好友")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(searchResults) { friend in
                        SearchResultRow(friend: friend) {
                            addFriend(friend)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("添加好友")
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
        let sampleNames = ["小明", "小红", "小李", "小王", "小张"]
        let randomNames = sampleNames.shuffled().prefix(3)
        
        return randomNames.map { name in
            Friend(
                name: name,
                level: Int.random(in: 1...20),
                isOnline: Bool.random(),
                lastActive: Date().addingTimeInterval(-Double.random(in: 0...86400))
            )
        }
    }
    
    private func addFriend(_ friend: Friend) {
        viewModel.addFriend(friend)
        
        // 显示添加成功提示
        withAnimation {
            searchResults.removeAll { $0.id == friend.id }
        }
    }
}

struct SearchResultRow: View {
    let friend: Friend
    let onAdd: () -> Void
    
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
            
            Button("添加") {
                onAdd()
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AddFriendView(viewModel: SocialLearningViewModel())
}
