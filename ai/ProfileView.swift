import SwiftUI

struct ProfileView: View {
    @Binding var userProgress: UserProgress
    @State private var showingSettings = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 用户信息卡片
                    userInfoCard
                    
                    // 学习统计
                    learningStatsCard
                    
                    // 功能菜单
                    menuSection
                    
                    // 关于信息
                    aboutSection
                }
                .padding(.vertical)
            }
            .navigationTitle("个人资料")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingSettings) {
                SettingsView(userProgress: $userProgress)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
    
    private var userInfoCard: some View {
        VStack(spacing: 20) {
            // 头像和用户名
            VStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 4) {
                    Text("AI学习者")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("等级 \(userProgress.level)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            // 成就徽章
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(userProgress.achievements.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("成就")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(userProgress.currentStreak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("连续天数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("\(userProgress.totalXP)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("总经验值")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var learningStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("学习统计")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Text("\(max(1, userProgress.totalXP / 10))")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("学习天数")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        Text("\(max(1, userProgress.totalXP / max(1, userProgress.totalXP / 10)))")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("平均每日XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.title3)
                            .foregroundColor(.orange)
                        
                        Text("\(userProgress.completedLessons.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("完成课程")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "speedometer")
                            .font(.title3)
                            .foregroundColor(.purple)
                        
                        Text("\(calculateLearningEfficiency())%")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("学习效率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var menuSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("功能")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                MenuRow(
                    title: "设置",
                    icon: "gear",
                    color: .blue
                ) {
                    showingSettings = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                MenuRow(
                    title: "学习提醒",
                    icon: "bell",
                    color: .green
                ) {
                    // 学习提醒功能
                }
                
                Divider()
                    .padding(.leading, 56)
                
                MenuRow(
                    title: "数据导出",
                    icon: "square.and.arrow.up",
                    color: .orange
                ) {
                    // 数据导出功能
                }
                
                Divider()
                    .padding(.leading, 56)
                
                MenuRow(
                    title: "帮助与反馈",
                    icon: "questionmark.circle",
                    color: .purple
                ) {
                    // 帮助与反馈功能
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("关于")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 1) {
                MenuRow(
                    title: "关于应用",
                    icon: "info.circle",
                    color: .blue
                ) {
                    showingAbout = true
                }
                
                Divider()
                    .padding(.leading, 56)
                
                MenuRow(
                    title: "隐私政策",
                    icon: "hand.raised",
                    color: .green
                ) {
                    // 隐私政策
                }
                
                Divider()
                    .padding(.leading, 56)
                
                MenuRow(
                    title: "用户协议",
                    icon: "doc.text",
                    color: .orange
                ) {
                    // 用户协议
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
    
    private func calculateLearningEfficiency() -> Int {
        // 基于完成课程和经验值计算学习效率
        let baseEfficiency = min(100, userProgress.completedLessons.count * 10)
        let xpBonus = min(20, userProgress.totalXP / 50)
        return min(100, baseEfficiency + xpBonus)
    }
}

// StatItem 已移动到 SharedComponents.swift

struct MenuRow: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var userProgress: UserProgress
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("学习提醒")) {
                    Toggle("每日学习提醒", isOn: $userProgress.dailyReminderEnabled)
                        .onChange(of: userProgress.dailyReminderEnabled) { newValue in
                            if newValue {
                                userProgress.scheduleDailyReminder()
                            } else {
                                userProgress.cancelDailyReminder()
                            }
                        }
                    
                    if userProgress.dailyReminderEnabled {
                        DatePicker("提醒时间", selection: $userProgress.reminderTime, displayedComponents: .hourAndMinute)
                            .onChange(of: userProgress.reminderTime) { _ in
                                if userProgress.dailyReminderEnabled {
                                    userProgress.scheduleDailyReminder()
                                }
                            }
                    }
                }
                
                Section(header: Text("应用信息")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("AI学习团队")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 关于视图
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 应用图标
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 100))
                        .foregroundColor(.blue)
                    
                    // 应用信息
                    VStack(spacing: 16) {
                        Text("AI学习助手")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("版本 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("一个专门用于学习人工智能知识的iOS应用，通过循序渐进的方式，帮助用户掌握AI的核心概念。")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // 功能特色
                    VStack(alignment: .leading, spacing: 12) {
                        Text("主要功能")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        FeatureRow(icon: "book.fill", text: "6门AI核心课程")
                        FeatureRow(icon: "brain.head.profile", text: "互动式学习体验")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "进度跟踪系统")
                        FeatureRow(icon: "star.fill", text: "成就和等级系统")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userProgress: .constant(UserProgress()))
    }
}
