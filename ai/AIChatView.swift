//
//  AIChatView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

struct AIChatView: View {
    @StateObject private var viewModel: AIChatViewModel
    @FocusState private var isInputFocused: Bool
    
    init(userProgress: UserProgress? = nil) {
        self._viewModel = StateObject(wrappedValue: AIChatViewModel(userProgress: userProgress))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 聊天消息列表
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                            
                            // 加载指示器
                            if viewModel.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(20)
                                    Spacer()
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // 为输入框留出空间
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                }
                
                // 底部输入区域
                VStack(spacing: 0) {
                    // 快速问题和建议按钮
                    if viewModel.messages.count <= 1 {
                        QuickActionsView(viewModel: viewModel)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
                    }
                    
                    // 输入框
                    HStack(spacing: 12) {
                        TextField("输入你的问题...", text: $viewModel.inputText, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isInputFocused)
                            .lineLimit(1...4)
                        
                        Button(action: {
                            viewModel.sendMessage()
                            isInputFocused = false
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                        }
                        .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                    .overlay(
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(.separator)),
                        alignment: .top
                    )
                }
            }
            .navigationTitle("AI助手")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("清空") {
                        viewModel.clearChat()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.toggleSuggestions()
                    }) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingSuggestions) {
            LearningSuggestionsView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingLearningPath) {
            LearningPathView(viewModel: viewModel)
        }
    }
}

// MARK: - 聊天消息视图
struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                messageContent
                userAvatar
            } else {
                aiAvatar
                messageContent
                Spacer()
            }
        }
    }
    
    private var messageContent: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
            Text(message.content)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(message.isUser ? Color.blue : Color(.systemGray6))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(20)
                .textSelection(.enabled)
            
            Text(formatTime(message.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
        }
    }
    
    private var userAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.title2)
            .foregroundColor(.blue)
    }
    
    private var aiAvatar: some View {
        Image(systemName: "brain.head.profile")
            .font(.title2)
            .foregroundColor(.purple)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 快速操作视图
struct QuickActionsView: View {
    @ObservedObject var viewModel: AIChatViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            // 快速问题
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 快速问题")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(viewModel.quickQuestions, id: \.self) { question in
                        Button(action: {
                            viewModel.sendQuickQuestion(question)
                        }) {
                            Text(question)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .lineLimit(2)
                        }
                    }
                }
            }
            
            // 学习建议
            VStack(alignment: .leading, spacing: 8) {
                Text("📚 学习建议")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.learningSuggestions) { suggestion in
                            Button(action: {
                                viewModel.sendSuggestion("我想了解\(suggestion.title)")
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(suggestion.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(suggestion.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        Text(suggestion.category)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.2))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                        
                                        Spacer()
                                        
                                        Text(suggestion.difficulty)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.green.opacity(0.2))
                                            .foregroundColor(.green)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(12)
                                .frame(width: 160)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - 学习建议视图
struct LearningSuggestionsView: View {
    @ObservedObject var viewModel: AIChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.learningSuggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(suggestion.title)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(suggestion.difficulty)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(difficultyColor(suggestion.difficulty))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        Text(suggestion.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(suggestion.category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            
                            Spacer()
                            
                            Text("预计时间: \(suggestion.estimatedTime)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.sendSuggestion("我想了解\(suggestion.title)")
                        dismiss()
                    }
                }
            }
            .navigationTitle("学习建议")
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
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "初级":
            return .green
        case "中级":
            return .orange
        case "高级":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 学习路径视图
struct LearningPathView: View {
    @ObservedObject var viewModel: AIChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = "机器学习"
    
    let categories = ["机器学习", "深度学习", "自然语言处理", "计算机视觉"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 类别选择器
                Picker("选择类别", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 学习路径内容
                ScrollView {
                    Text(viewModel.generateLearningPath(for: selectedCategory))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("学习路径")
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
}

struct AIChatView_Previews: PreviewProvider {
    static var previews: some View {
        AIChatView()
    }
}
