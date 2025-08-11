import SwiftUI

struct LessonView: View {
    let lesson: Lesson
    @Binding var userProgress: UserProgress
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep: LessonStep = .content
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var showExplanation = false
    @State private var isCompleted = false
    
    enum LessonStep {
        case content
        case quiz
        case completed
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 进度指示器
                progressIndicator
                
                // 内容区域
                Group {
                    switch currentStep {
                    case .content:
                        lessonContent
                    case .quiz:
                        quizView
                    case .completed:
                        completionView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            // 检查是否已完成
            if userProgress.completedLessons.contains(lesson.id) {
                isCompleted = true
            }
        }
    }
    
    private var progressIndicator: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(currentStep == .content ? Color.blue : Color.gray.opacity(0.3))
                .frame(height: 4)
            
            Rectangle()
                .fill(currentStep == .quiz ? Color.blue : Color.gray.opacity(0.3))
                .frame(height: 4)
            
            Rectangle()
                .fill(currentStep == .completed ? Color.blue : Color.green)
                .frame(height: 4)
        }
        .padding(.horizontal)
    }
    
    private var lessonContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 内容标题
                Text(lesson.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // 内容正文
                Text(lesson.content)
                    .font(.body)
                    .lineSpacing(6)
                    .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
            .padding(.top)
        }
        .overlay(
            VStack {
                Spacer()
                
                // 继续按钮
                Button(action: {
                    withAnimation {
                        currentStep = .quiz
                    }
                }) {
                    Text("开始测验")
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
        )
    }
    
    private var quizView: some View {
        VStack(spacing: 20) {
            if currentQuestionIndex < lesson.questions.count {
                let question = lesson.questions[currentQuestionIndex]
                
                // 问题进度
                HStack {
                    Text("问题 \(currentQuestionIndex + 1) / \(lesson.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
                        showExplanation = true
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
        .alert("答案解释", isPresented: $showExplanation) {
            Button("继续") {
                showExplanation = false
                nextQuestion()
            }
        } message: {
            let question = lesson.questions[currentQuestionIndex]
            let isCorrect = selectedAnswer == question.correctAnswer
            Text("\(isCorrect ? "回答正确！" : "回答错误。") \(question.explanation)")
        }
    }
    
    private var completionView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 完成图标
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // 完成信息
            VStack(spacing: 16) {
                Text("恭喜完成！")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("你已成功完成「\(lesson.title)」单元")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // 获得的经验值
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    
                    Text("+10 经验值")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
            
            Spacer()
            
            // 完成按钮
            Button(action: {
                if !isCompleted {
                    userProgress.completeLesson(lesson.id)
                    isCompleted = true
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("完成")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(16)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    private func nextQuestion() {
        if currentQuestionIndex < lesson.questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = nil
        } else {
            withAnimation {
                currentStep = .completed
            }
        }
    }
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleLesson = Lesson(
            title: "什么是人工智能？",
            content: "人工智能（AI）是计算机科学的一个分支...",
            type: .theory,
            questions: [],
            isCompleted: false
        )
        
        LessonView(lesson: sampleLesson, userProgress: .constant(UserProgress()))
    }
}
