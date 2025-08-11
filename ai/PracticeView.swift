import SwiftUI

struct PracticeView: View {
    @Binding var userProgress: UserProgress
    @StateObject private var courseData = CourseData()
    @State private var selectedPracticeType: PracticeType = .daily
    @State private var currentQuestions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showResult = false
    @State private var score = 0
    @State private var practiceCompleted = false
    
    enum PracticeType: String, CaseIterable {
        case daily = "每日练习"
        case random = "随机测验"
        case review = "复习模式"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 练习类型选择
                practiceTypeSelector
                
                if currentQuestions.isEmpty {
                    // 开始练习界面
                    startPracticeView
                } else if practiceCompleted {
                    // 练习完成界面
                    practiceResultView
                } else {
                    // 练习进行中界面
                    practiceInProgressView
                }
                
                Spacer()
            }
            .navigationTitle("练习")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var practiceTypeSelector: some View {
        VStack(spacing: 16) {
            Text("选择练习类型")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 12) {
                ForEach(PracticeType.allCases, id: \.self) { type in
                    Button(action: {
                        selectedPracticeType = type
                    }) {
                        Text(type.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedPracticeType == type ? .white : .blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedPracticeType == type ? Color.blue : Color.blue.opacity(0.1))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var startPracticeView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 练习图标
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            // 练习说明
            VStack(spacing: 16) {
                Text("开始\(selectedPracticeType.rawValue)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(practiceDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // 开始按钮
            Button(action: {
                startPractice()
            }) {
                Text("开始练习")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var practiceInProgressView: some View {
        VStack(spacing: 20) {
            if currentQuestionIndex < currentQuestions.count {
                let question = currentQuestions[currentQuestionIndex]
                
                // 进度指示器
                HStack {
                    Text("问题 \(currentQuestionIndex + 1) / \(currentQuestions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("得分: \(score)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // 问题内容
                Text(question.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                // 选项
                VStack(spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        Button(action: {
                            selectedAnswer = index
                        }) {
                            HStack {
                                Text(question.options[index])
                                    .font(.body)
                                    .foregroundColor(selectedAnswer == index ? .white : .primary)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                                
                                if selectedAnswer == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedAnswer == index ? Color.blue : Color(.systemGray6))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 提交按钮
                Button(action: {
                    if let selectedAnswer = selectedAnswer {
                        submitAnswer(selectedAnswer, for: question)
                    }
                }) {
                    Text(selectedAnswer != nil ? "提交答案" : "选择答案")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedAnswer != nil ? Color.blue : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(selectedAnswer == nil)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .alert("答案结果", isPresented: $showResult) {
            Button("继续") {
                showResult = false
                nextQuestion()
            }
        } message: {
            let question = currentQuestions[currentQuestionIndex]
            let isCorrect = selectedAnswer == question.correctAnswer
            Text("\(isCorrect ? "回答正确！" : "回答错误。") \(question.explanation)")
        }
    }
    
    private var practiceResultView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 结果图标
            let percentage = Double(score) / Double(currentQuestions.count)
            Image(systemName: percentage >= 0.8 ? "star.fill" : percentage >= 0.6 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(percentage >= 0.8 ? .yellow : percentage >= 0.6 ? .green : .orange)
            
            // 结果信息
            VStack(spacing: 16) {
                Text(resultTitle)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("你的得分: \(score)/\(currentQuestions.count)")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text(resultMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // 获得的经验值
                let earnedXP = calculateEarnedXP()
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("+\(earnedXP) 经验值")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // 重新开始按钮
            Button(action: {
                resetPractice()
            }) {
                Text("再来一次")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    private var practiceDescription: String {
        switch selectedPracticeType {
        case .daily:
            return "每天5道精选题目，巩固你的AI知识"
        case .random:
            return "随机抽取10道题目，测试你的综合能力"
        case .review:
            return "复习已学过的内容，加深理解"
        }
    }
    
    private var resultTitle: String {
        let percentage = Double(score) / Double(currentQuestions.count)
        if percentage >= 0.8 {
            return "太棒了！"
        } else if percentage >= 0.6 {
            return "做得不错！"
        } else {
            return "继续加油！"
        }
    }
    
    private var resultMessage: String {
        let percentage = Double(score) / Double(currentQuestions.count)
        if percentage >= 0.8 {
            return "你的AI知识掌握得很好，继续保持！"
        } else if percentage >= 0.6 {
            return "你对AI有一定了解，还有提升空间"
        } else {
            return "建议多复习课程内容，加深理解"
        }
    }
    
    private func startPractice() {
        currentQuestions = generateQuestions()
        currentQuestionIndex = 0
        score = 0
        practiceCompleted = false
        selectedAnswer = nil
    }
    
    private func generateQuestions() -> [Question] {
        var allQuestions: [Question] = []
        
        // 收集所有课程的问题
        for course in courseData.courses {
            for lesson in course.lessons {
                allQuestions.append(contentsOf: lesson.questions)
            }
        }
        
        // 根据练习类型选择问题
        switch selectedPracticeType {
        case .daily:
            // 每日练习：5道题
            return Array(allQuestions.shuffled().prefix(5))
        case .random:
            // 随机测验：10道题
            return Array(allQuestions.shuffled().prefix(10))
        case .review:
            // 复习模式：已完成课程的问题
            let completedQuestions = allQuestions.filter { question in
                courseData.courses.contains { course in
                    course.lessons.contains { lesson in
                        lesson.questions.contains { $0.id == question.id } &&
                        userProgress.completedLessons.contains(lesson.id)
                    }
                }
            }
            return Array(completedQuestions.shuffled().prefix(8))
        }
    }
    
    private func submitAnswer(_ answer: Int, for question: Question) {
        if answer == question.correctAnswer {
            score += 1
        }
        showResult = true
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < currentQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
        } else {
            practiceCompleted = true
            // 添加经验值
            let earnedXP = calculateEarnedXP()
            userProgress.totalXP += earnedXP
        }
    }
    
    private func calculateEarnedXP() -> Int {
        let percentage = Double(score) / Double(currentQuestions.count)
        if percentage >= 0.8 {
            return 15
        } else if percentage >= 0.6 {
            return 10
        } else {
            return 5
        }
    }
    
    private func resetPractice() {
        currentQuestions = []
        currentQuestionIndex = 0
        score = 0
        practiceCompleted = false
        selectedAnswer = nil
    }
}

struct PracticeView_Previews: PreviewProvider {
    static var previews: some View {
        PracticeView(userProgress: .constant(UserProgress()))
    }
}
