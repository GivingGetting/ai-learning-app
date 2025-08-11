import Foundation

// MARK: - 课程数据
class CourseData: ObservableObject {
    @Published var courses: [Course] = []
    
    init() {
        loadCourses()
    }
    
    private func loadCourses() {
        courses = [
            // 基础AI概念课程
            Course(
                title: "AI基础入门",
                description: "了解人工智能的基本概念和发展历史",
                difficulty: .beginner,
                lessons: createBasicAILessons(),
                icon: "brain.head.profile",
                color: "blue"
            ),
            
            // 机器学习基础
            Course(
                title: "机器学习基础",
                description: "学习机器学习的核心概念和算法",
                difficulty: .beginner,
                lessons: createMachineLearningLessons(),
                icon: "chart.line.uptrend.xyaxis",
                color: "green"
            ),
            
            // 深度学习
            Course(
                title: "深度学习入门",
                description: "探索神经网络和深度学习的奥秘",
                difficulty: .intermediate,
                lessons: createDeepLearningLessons(),
                icon: "network",
                color: "purple"
            ),
            
            // 自然语言处理
            Course(
                title: "自然语言处理",
                description: "学习如何让计算机理解人类语言",
                difficulty: .intermediate,
                lessons: createNLPLessons(),
                icon: "text.bubble",
                color: "orange"
            ),
            
            // 计算机视觉
            Course(
                title: "计算机视觉",
                description: "让计算机学会‘看’和理解图像",
                difficulty: .intermediate,
                lessons: createComputerVisionLessons(),
                icon: "eye",
                color: "red"
            ),
            
            // AI伦理与未来
            Course(
                title: "AI伦理与未来",
                description: "探讨AI发展的伦理问题和未来趋势",
                difficulty: .advanced,
                lessons: createAIEthicsLessons(),
                icon: "lightbulb",
                color: "yellow"
            ),
            
            // 强化学习
            Course(
                title: "强化学习",
                description: "学习AI如何通过试错来优化决策",
                difficulty: .advanced,
                lessons: createReinforcementLearningLessons(),
                icon: "arrow.triangle.2.circlepath",
                color: "indigo"
            ),
            
            // 生成式AI
            Course(
                title: "生成式AI",
                description: "探索AI创作内容的能力和原理",
                difficulty: .intermediate,
                lessons: createGenerativeAILessons(),
                icon: "wand.and.stars",
                color: "pink"
            ),
            
            // AI工具应用
            Course(
                title: "AI工具应用",
                description: "学习使用各种AI工具提升工作效率",
                difficulty: .beginner,
                lessons: createAIToolsLessons(),
                icon: "hammer",
                color: "teal"
            ),
            
            // 大语言模型
            Course(
                title: "大语言模型",
                description: "深入了解GPT、BERT等大语言模型",
                difficulty: .advanced,
                lessons: createLargeLanguageModelLessons(),
                icon: "textformat.abc",
                color: "mint"
            ),
            
            // AI创业与商业
            Course(
                title: "AI创业与商业",
                description: "AI技术在商业领域的应用和创业机会",
                difficulty: .intermediate,
                lessons: createAIBusinessLessons(),
                icon: "building.2",
                color: "brown"
            )
        ]
    }
    
    private func createBasicAILessons() -> [Lesson] {
        return [
            Lesson(
                title: "什么是人工智能？",
                content: "人工智能（AI）是计算机科学的一个分支，旨在创建能够执行通常需要人类智能的任务的系统。这些任务包括学习、推理、问题解决、感知和语言理解。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI是哪个领域的缩写？",
                        options: ["Artificial Intelligence", "Advanced Internet", "Automated Information", "Applied Intelligence"],
                        correctAnswer: 0,
                        explanation: "AI是Artificial Intelligence（人工智能）的缩写",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "AI系统能够执行哪些任务？",
                        options: ["学习", "推理", "问题解决", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI系统能够执行学习、推理、问题解决等多种任务",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI的发展历史",
                content: "人工智能的概念可以追溯到1950年代。1956年，在达特茅斯会议上，'人工智能'这个术语首次被正式提出。从那时起，AI经历了多次发展浪潮，包括专家系统、机器学习革命，以及当前的深度学习时代。",
                type: .theory,
                questions: [
                    Question(
                        question: "人工智能这个术语是在哪一年正式提出的？",
                        options: ["1950年", "1956年", "1960年", "1970年"],
                        correctAnswer: 1,
                        explanation: "1956年，在达特茅斯会议上，'人工智能'这个术语首次被正式提出",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI的类型",
                content: "人工智能可以分为三种主要类型：1. 弱AI（狭义AI）：专门执行特定任务的AI，如语音识别或图像分类。2. 强AI（通用AI）：具有与人类相当或超越人类的智能水平。3. 超级AI：在所有认知任务上都超越人类的AI。",
                type: .theory,
                questions: [
                    Question(
                        question: "目前我们使用的AI系统主要属于哪种类型？",
                        options: ["弱AI", "强AI", "超级AI", "混合AI"],
                        correctAnswer: 0,
                        explanation: "目前我们使用的AI系统主要属于弱AI，它们专门执行特定任务",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createMachineLearningLessons() -> [Lesson] {
        return [
            Lesson(
                title: "机器学习概述",
                content: "机器学习是AI的一个子集，它使计算机能够在没有明确编程的情况下学习和改进。机器学习算法通过分析数据来识别模式，并使用这些模式来做出预测或决策。",
                type: .theory,
                questions: [
                    Question(
                        question: "机器学习的主要目标是什么？",
                        options: ["让计算机更快运行", "让计算机在没有明确编程的情况下学习", "减少计算机的能耗", "增加计算机的存储空间"],
                        correctAnswer: 1,
                        explanation: "机器学习的主要目标是让计算机能够在没有明确编程的情况下学习和改进",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "监督学习",
                content: "监督学习是机器学习的一种方法，其中算法从标记的训练数据中学习。训练数据包含输入和期望的输出，算法学习将输入映射到输出的函数。常见的监督学习算法包括线性回归、逻辑回归、决策树和神经网络。",
                type: .theory,
                questions: [
                    Question(
                        question: "监督学习需要什么类型的数据？",
                        options: ["未标记的数据", "标记的训练数据", "随机数据", "加密数据"],
                        correctAnswer: 1,
                        explanation: "监督学习需要标记的训练数据，包含输入和期望的输出",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createDeepLearningLessons() -> [Lesson] {
        return [
            Lesson(
                title: "神经网络基础",
                content: "神经网络是受人类大脑启发的计算模型。它们由相互连接的节点（神经元）组成，这些节点处理信息并传递信号。神经网络能够学习复杂的模式，并在图像识别、自然语言处理等任务中表现出色。",
                type: .theory,
                questions: [
                    Question(
                        question: "神经网络的设计灵感来自什么？",
                        options: ["计算机芯片", "人类大脑", "电路板", "数据库"],
                        correctAnswer: 1,
                        explanation: "神经网络是受人类大脑启发的计算模型",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createNLPLessons() -> [Lesson] {
        return [
            Lesson(
                title: "自然语言处理简介",
                content: "自然语言处理（NLP）是AI的一个分支，专注于使计算机能够理解、解释和生成人类语言。NLP技术被用于机器翻译、情感分析、聊天机器人、语音识别等应用。",
                type: .theory,
                questions: [
                    Question(
                        question: "NLP的主要目标是什么？",
                        options: ["让计算机更快运行", "让计算机理解人类语言", "减少计算机的能耗", "增加计算机的存储空间"],
                        correctAnswer: 1,
                        explanation: "NLP的主要目标是使计算机能够理解、解释和生成人类语言",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createComputerVisionLessons() -> [Lesson] {
        return [
            Lesson(
                title: "计算机视觉基础",
                content: "计算机视觉是AI的一个分支，旨在使计算机能够从数字图像或视频中获取高级理解。它涉及开发算法和技术，使计算机能够识别、分类和理解视觉信息。",
                type: .theory,
                questions: [
                    Question(
                        question: "计算机视觉的主要目标是什么？",
                        options: ["让计算机更快运行", "让计算机理解视觉信息", "减少计算机的能耗", "增加计算机的存储空间"],
                        correctAnswer: 1,
                        explanation: "计算机视觉的主要目标是使计算机能够从数字图像或视频中获取高级理解",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIEthicsLessons() -> [Lesson] {
        return [
            Lesson(
                title: "AI伦理问题",
                content: "随着AI技术的发展，出现了许多伦理问题，包括隐私、偏见、就业影响、自主武器等。了解这些伦理问题对于负责任地开发和使用AI技术至关重要。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI伦理主要关注哪些问题？",
                        options: ["技术性能", "隐私和偏见", "硬件成本", "软件界面"],
                        correctAnswer: 1,
                        explanation: "AI伦理主要关注隐私、偏见、就业影响、自主武器等伦理问题",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createReinforcementLearningLessons() -> [Lesson] {
        return [
            Lesson(
                title: "强化学习概述",
                content: "强化学习是一种机器学习范式，其中智能体通过与环境的交互来学习如何做出最优决策。它通过奖励和惩罚来指导学习过程，使智能体能够从试错中获得经验，并逐步改进其策略。",
                type: .theory,
                questions: [
                    Question(
                        question: "强化学习的主要目标是？",
                        options: ["让计算机更快运行", "让计算机在没有明确编程的情况下学习", "让计算机能够做出最优决策", "减少计算机的能耗"],
                        correctAnswer: 2,
                        explanation: "强化学习的主要目标是让计算机能够做出最优决策",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "强化学习中的智能体通过什么方式学习？",
                        options: ["阅读文档", "与人类交流", "与环境交互", "观看视频"],
                        correctAnswer: 2,
                        explanation: "强化学习中的智能体通过与环境的交互来学习",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "Q-Learning算法",
                content: "Q-Learning是强化学习中最经典的算法之一。它通过Q表来存储状态-动作对的价值，智能体通过不断更新Q值来学习最优策略。Q-Learning的核心思想是平衡探索和利用。",
                type: .theory,
                questions: [
                    Question(
                        question: "Q-Learning的核心思想是什么？",
                        options: ["快速计算", "平衡探索和利用", "减少内存使用", "提高算法效率"],
                        correctAnswer: 1,
                        explanation: "Q-Learning的核心思想是平衡探索和利用",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createGenerativeAILessons() -> [Lesson] {
        return [
            Lesson(
                title: "生成式AI简介",
                content: "生成式AI是AI的一个分支，它使计算机能够生成新的、原创的、看似自然的文本、图像、音频或视频。这些模型通常基于大型预训练语言模型（如GPT-4）或大型图像生成模型（如Stable Diffusion）。",
                type: .theory,
                questions: [
                    Question(
                        question: "生成式AI的主要应用是什么？",
                        options: ["让计算机更快运行", "让计算机理解人类语言", "让计算机生成原创内容", "减少计算机的能耗"],
                        correctAnswer: 2,
                        explanation: "生成式AI的主要应用是让计算机生成原创内容",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "以下哪个是生成式AI的例子？",
                        options: ["GPT-4", "Excel", "Photoshop", "Chrome浏览器"],
                        correctAnswer: 0,
                        explanation: "GPT-4是生成式AI的例子，能够生成文本内容",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "文本生成技术",
                content: "文本生成是生成式AI的重要应用领域。现代文本生成模型能够创作文章、诗歌、对话等各类文本内容。这些模型通过大规模文本训练，学会了语言的语法、语义和风格。",
                type: .theory,
                questions: [
                    Question(
                        question: "现代文本生成模型通过什么方式学习？",
                        options: ["人工编程", "大规模文本训练", "观看视频", "听音频"],
                        correctAnswer: 1,
                        explanation: "现代文本生成模型通过大规模文本训练来学习",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIToolsLessons() -> [Lesson] {
        return [
            Lesson(
                title: "AI工具概述",
                content: "AI工具是帮助用户利用AI能力的软件或平台。它们可以用于各种任务，如数据分析、内容创作、自动化、预测等。常见的AI工具包括ChatGPT、Midjourney、Auto-GPT等。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI工具的主要作用是什么？",
                        options: ["让计算机更快运行", "让用户更容易使用AI能力", "让计算机生成原创内容", "减少计算机的能耗"],
                        correctAnswer: 1,
                        explanation: "AI工具的主要作用是让用户更容易使用AI能力",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "以下哪个是AI工具的例子？",
                        options: ["ChatGPT", "Word", "Excel", "PowerPoint"],
                        correctAnswer: 0,
                        explanation: "ChatGPT是AI工具的例子，能够进行对话和内容生成",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI工具分类",
                content: "AI工具可以按照功能分为多个类别：文本生成工具（如ChatGPT）、图像生成工具（如Midjourney）、代码生成工具（如GitHub Copilot）、数据分析工具（如Tableau AI）等。每种工具都有其特定的应用场景。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI工具按功能可以分为几类？",
                        options: ["2类", "3类", "4类", "多类"],
                        correctAnswer: 3,
                        explanation: "AI工具按功能可以分为多类，包括文本生成、图像生成、代码生成、数据分析等",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createLargeLanguageModelLessons() -> [Lesson] {
        return [
            Lesson(
                title: "大语言模型概述",
                content: "大语言模型（LLM）是AI领域中规模最大、能力最强的预训练语言模型。它们通常具有数十亿到数万亿个参数，能够理解和生成极其复杂的语言。GPT-4、BERT、LLaMA等都是大语言模型的例子。",
                type: .theory,
                questions: [
                    Question(
                        question: "大语言模型的主要特点是什么？",
                        options: ["体积小", "参数数量巨大", "运行速度快", "能耗低"],
                        correctAnswer: 1,
                        explanation: "大语言模型的主要特点是参数数量巨大，通常有数十亿到数万亿个参数",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "以下哪个是大语言模型的例子？",
                        options: ["GPT-4", "Excel", "Photoshop", "Chrome浏览器"],
                        correctAnswer: 0,
                        explanation: "GPT-4是大语言模型的例子",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "Transformer架构",
                content: "Transformer是现代大语言模型的基础架构。它使用注意力机制来处理序列数据，能够并行处理输入，大大提高了训练和推理效率。Transformer的出现彻底改变了自然语言处理领域。",
                type: .theory,
                questions: [
                    Question(
                        question: "Transformer架构的核心是什么？",
                        options: ["循环神经网络", "注意力机制", "卷积神经网络", "全连接层"],
                        correctAnswer: 1,
                        explanation: "Transformer架构的核心是注意力机制",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIBusinessLessons() -> [Lesson] {
        return [
            Lesson(
                title: "AI在商业中的应用",
                content: "AI技术在商业领域有广泛的应用，包括市场分析、客户服务、产品推荐、风险预测等。了解这些应用对于企业利用AI提升竞争力至关重要。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI在商业中的主要应用包括哪些？",
                        options: ["市场分析", "客户服务", "产品推荐", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI在商业中的主要应用包括市场分析、客户服务、产品推荐、风险预测等",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "AI技术对企业的主要价值是什么？",
                        options: ["降低硬件成本", "提升竞争力", "减少员工数量", "简化管理流程"],
                        correctAnswer: 1,
                        explanation: "AI技术对企业的主要价值是提升竞争力",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI创业机会",
                content: "AI技术的快速发展为创业者提供了大量机会。从AI工具开发到AI咨询服务，从垂直领域应用到AI基础设施，创业者可以在多个方向探索商业机会。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI创业的主要方向包括哪些？",
                        options: ["AI工具开发", "AI咨询服务", "垂直领域应用", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI创业的主要方向包括AI工具开发、AI咨询服务、垂直领域应用等",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
}
