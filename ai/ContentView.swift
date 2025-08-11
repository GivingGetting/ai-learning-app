//
//  ContentView.swift
//  ai
//
//  Created by Donghui Liu on 8/10/25.
//

import SwiftUI

// 确保所有视图类型都能被正确识别
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var userProgress = UserProgress()
    @State private var showingSplash = true
    
    var body: some View {
        ZStack {
            if showingSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showingSplash = false
                            }
                        }
                    }
            } else {
                TabView(selection: $selectedTab) {
                    CourseListView(userProgress: $userProgress)
                        .tabItem {
                            Image(systemName: "book.fill")
                            Text("课程")
                        }
                        .tag(0)
                    
                    PracticeView(userProgress: $userProgress)
                        .tabItem {
                            Image(systemName: "brain.head.profile")
                            Text("练习")
                        }
                        .tag(1)
                    
                    AIChatView(userProgress: userProgress)
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("AI助手")
                        }
                        .tag(2)
                    
                    StudyPlanView()
                        .tabItem {
                            Image(systemName: "calendar.badge.plus")
                            Text("学习计划")
                        }
                        .tag(3)
                    
                    SocialLearningView()
                        .tabItem {
                            Image(systemName: "person.3.fill")
                            Text("社交学习")
                        }
                        .tag(4)
                    
                    ProgressView(userProgress: $userProgress)
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("进度")
                        }
                        .tag(5)
                    
                    ProfileView(userProgress: $userProgress)
                        .tabItem {
                            Image(systemName: "person.circle.fill")
                            Text("我的")
                        }
                        .tag(6)
                }
                .accentColor(.blue)
            }
        }
    }
}



// MARK: - 启动画面
struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // 应用名称
                Text("AI学习助手")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(textOpacity)
                
                // 副标题
                Text("开启你的AI学习之旅")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
