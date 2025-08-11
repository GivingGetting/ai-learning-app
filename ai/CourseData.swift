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
            
            // 强化学习
            Course(
                title: "强化学习",
                description: "通过试错学习最优策略的AI方法",
                difficulty: .intermediate,
                lessons: createReinforcementLearningLessons(),
                icon: "gamecontroller",
                color: "indigo"
            ),
            
            // 大语言模型
            Course(
                title: "大语言模型",
                description: "探索GPT、BERT等大型语言模型的原理和应用",
                difficulty: .advanced,
                lessons: createLargeLanguageModelLessons(),
                icon: "textformat.size.larger",
                color: "teal"
            ),
            
            // AI在医疗健康中的应用
            Course(
                title: "AI医疗健康",
                description: "AI技术在医疗诊断、药物发现和健康管理中的应用",
                difficulty: .intermediate,
                lessons: createAIHealthcareLessons(),
                icon: "heart.text.square",
                color: "pink"
            ),
            
            // AI在金融科技中的应用
            Course(
                title: "AI金融科技",
                description: "AI在金融风险评估、智能投顾和反欺诈中的应用",
                difficulty: .intermediate,
                lessons: createAIFintechLessons(),
                icon: "dollarsign.circle",
                color: "mint"
            ),
            
            // AI在教育技术中的应用
            Course(
                title: "AI教育技术",
                description: "AI驱动的个性化学习和智能教育系统",
                difficulty: .beginner,
                lessons: createAIEdTechLessons(),
                icon: "graduationcap",
                color: "cyan"
            ),
            
            // AI在自动驾驶中的应用
            Course(
                title: "AI自动驾驶",
                description: "计算机视觉和AI在自动驾驶汽车中的应用",
                difficulty: .advanced,
                lessons: createAIAutonomousDrivingLessons(),
                icon: "car",
                color: "brown"
            ),
            
            // AI在游戏开发中的应用
            Course(
                title: "AI游戏开发",
                description: "AI在游戏角色行为、关卡生成和玩家体验中的应用",
                difficulty: .intermediate,
                lessons: createAIGameDevLessons(),
                icon: "gamecontroller.fill",
                color: "purple"
            ),
            
            // AI伦理与未来
            Course(
                title: "AI伦理与未来",
                description: "探讨AI发展的伦理问题和未来趋势",
                difficulty: .advanced,
                lessons: createAIEthicsLessons(),
                icon: "lightbulb",
                color: "yellow"
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
            ),
            Lesson(
                title: "无监督学习",
                content: "无监督学习是机器学习的另一种方法，其中算法从未标记的数据中学习。无监督学习的目标是发现数据中的隐藏模式、结构或关系，而不需要预先知道输出结果。常见的无监督学习算法包括聚类、降维和关联规则挖掘。",
                type: .theory,
                questions: [
                    Question(
                        question: "无监督学习的主要特点是什么？",
                        options: ["需要标记数据", "不需要标记数据", "需要大量计算资源", "只能处理数值数据"],
                        correctAnswer: 1,
                        explanation: "无监督学习的主要特点是不需要标记数据",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "线性回归",
                content: "线性回归是监督学习中最基础和常用的算法之一。它通过拟合一条直线来建立输入变量和输出变量之间的线性关系。线性回归广泛应用于房价预测、销售预测、风险评估等场景。",
                type: .theory,
                questions: [
                    Question(
                        question: "线性回归适用于什么类型的问题？",
                        options: ["分类问题", "回归问题", "聚类问题", "强化学习"],
                        correctAnswer: 1,
                        explanation: "线性回归适用于回归问题，即预测连续数值",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "决策树",
                content: "决策树是一种树形结构的机器学习模型，它通过一系列的问题来做出决策。决策树易于理解和解释，可以处理数值和分类数据，广泛应用于分类和回归任务。",
                type: .theory,
                questions: [
                    Question(
                        question: "决策树的主要优势是什么？",
                        options: ["计算速度快", "易于理解和解释", "处理大数据集", "以上都是"],
                        correctAnswer: 3,
                        explanation: "决策树具有计算速度快、易于理解和解释、处理大数据集等优势",
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
            ),
            Lesson(
                title: "反向传播算法",
                content: "反向传播是训练神经网络的核心算法。它通过计算损失函数对网络参数的梯度，然后使用梯度下降来更新参数。反向传播算法使得深度神经网络能够有效地学习复杂的非线性映射。",
                type: .theory,
                questions: [
                    Question(
                        question: "反向传播算法的主要作用是什么？",
                        options: ["前向计算", "参数更新", "数据预处理", "模型评估"],
                        correctAnswer: 1,
                        explanation: "反向传播算法的主要作用是更新网络参数",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "卷积神经网络（CNN）",
                content: "卷积神经网络是专门用于处理网格结构数据（如图像）的深度学习模型。CNN通过卷积层、池化层和全连接层的组合，能够自动提取图像的特征，在图像分类、目标检测等任务中取得了突破性进展。",
                type: .theory,
                questions: [
                    Question(
                        question: "CNN主要用于处理什么类型的数据？",
                        options: ["文本数据", "图像数据", "音频数据", "时间序列数据"],
                        correctAnswer: 1,
                        explanation: "CNN主要用于处理图像数据",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "循环神经网络（RNN）",
                content: "循环神经网络是专门用于处理序列数据的神经网络。RNN具有记忆能力，能够处理变长序列，广泛应用于自然语言处理、语音识别、时间序列预测等任务。",
                type: .theory,
                questions: [
                    Question(
                        question: "RNN的主要特点是什么？",
                        options: ["处理序列数据", "具有记忆能力", "可以处理变长序列", "以上都是"],
                        correctAnswer: 3,
                        explanation: "RNN具有处理序列数据、记忆能力、处理变长序列等特点",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "长短期记忆网络（LSTM）",
                content: "LSTM是RNN的一种改进版本，专门解决RNN的长期依赖问题。LSTM通过门控机制来控制信息的流动，能够更好地记住长期信息，在机器翻译、文本生成等任务中表现出色。",
                type: .theory,
                questions: [
                    Question(
                        question: "LSTM解决了RNN的什么问题？",
                        options: ["计算速度慢", "长期依赖问题", "参数过多", "梯度爆炸"],
                        correctAnswer: 1,
                        explanation: "LSTM解决了RNN的长期依赖问题",
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
            ),
            Lesson(
                title: "文本预处理",
                content: "文本预处理是NLP任务的第一步，包括分词、词性标注、命名实体识别、去除停用词等。良好的文本预处理能够显著提高后续NLP任务的性能。",
                type: .theory,
                questions: [
                    Question(
                        question: "文本预处理不包括以下哪个步骤？",
                        options: ["分词", "词性标注", "图像识别", "去除停用词"],
                        correctAnswer: 2,
                        explanation: "图像识别不是文本预处理的步骤",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "词向量（Word Embeddings）",
                content: "词向量是将词汇映射到高维向量空间的表示方法，能够捕获词汇之间的语义关系。Word2Vec、GloVe等词向量模型在NLP任务中得到了广泛应用。",
                type: .theory,
                questions: [
                    Question(
                        question: "词向量的主要作用是什么？",
                        options: ["压缩文本", "捕获语义关系", "加密信息", "美化界面"],
                        correctAnswer: 1,
                        explanation: "词向量的主要作用是捕获词汇之间的语义关系",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "机器翻译",
                content: "机器翻译是NLP的重要应用之一，旨在将一种语言的文本自动翻译成另一种语言。从早期的统计机器翻译到现在的神经机器翻译，翻译质量得到了显著提升。",
                type: .theory,
                questions: [
                    Question(
                        question: "现代机器翻译主要基于什么技术？",
                        options: ["统计方法", "神经网络", "规则系统", "专家系统"],
                        correctAnswer: 1,
                        explanation: "现代机器翻译主要基于神经网络技术",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "情感分析",
                content: "情感分析是NLP的一个分支，旨在识别文本中表达的情感倾向（如正面、负面、中性）。情感分析在社交媒体监控、产品评论分析、市场研究等领域有重要应用。",
                type: .theory,
                questions: [
                    Question(
                        question: "情感分析主要用于识别什么？",
                        options: ["文本长度", "语言类型", "情感倾向", "语法结构"],
                        correctAnswer: 2,
                        explanation: "情感分析主要用于识别文本中的情感倾向",
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
            ),
            Lesson(
                title: "图像预处理",
                content: "图像预处理是计算机视觉任务的重要步骤，包括图像缩放、噪声去除、对比度增强、边缘检测等。良好的预处理能够显著提高后续视觉任务的性能。",
                type: .theory,
                questions: [
                    Question(
                        question: "图像预处理的主要目的是什么？",
                        options: ["增加图像大小", "提高后续任务性能", "减少存储空间", "美化图像"],
                        correctAnswer: 1,
                        explanation: "图像预处理的主要目的是提高后续视觉任务的性能",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "特征提取",
                content: "特征提取是计算机视觉的核心任务，旨在从图像中提取有意义的特征。传统方法包括SIFT、HOG等，现代方法主要基于深度学习自动学习特征。",
                type: .theory,
                questions: [
                    Question(
                        question: "现代计算机视觉主要使用什么方法提取特征？",
                        options: ["手工设计", "深度学习", "统计方法", "规则系统"],
                        correctAnswer: 1,
                        explanation: "现代计算机视觉主要使用深度学习自动学习特征",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "图像分类",
                content: "图像分类是计算机视觉的基础任务，旨在将图像分配到预定义的类别中。深度学习模型如CNN在ImageNet等大规模数据集上的表现已经超过人类水平。",
                type: .theory,
                questions: [
                    Question(
                        question: "图像分类的主要任务是什么？",
                        options: ["检测物体位置", "识别图像类别", "分割图像区域", "生成图像描述"],
                        correctAnswer: 1,
                        explanation: "图像分类的主要任务是识别图像属于哪个预定义类别",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "目标检测",
                content: "目标检测是计算机视觉的重要任务，不仅要识别图像中的物体类别，还要定位物体的位置。YOLO、R-CNN等算法在目标检测任务中取得了显著进展。",
                type: .theory,
                questions: [
                    Question(
                        question: "目标检测与图像分类的区别是什么？",
                        options: ["目标检测更简单", "目标检测需要定位物体位置", "图像分类更准确", "没有区别"],
                        correctAnswer: 1,
                        explanation: "目标检测不仅需要识别物体类别，还需要定位物体的位置",
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
            ),
            Lesson(
                title: "AI偏见与公平性",
                content: "AI系统可能继承训练数据中的偏见，导致对某些群体的不公平对待。确保AI系统的公平性和减少偏见是AI伦理的重要议题，需要从数据收集、算法设计、模型评估等多个环节进行控制。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI偏见的主要来源是什么？",
                        options: ["硬件故障", "训练数据", "网络延迟", "用户界面"],
                        correctAnswer: 1,
                        explanation: "AI偏见的主要来源是训练数据中存在的偏见",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI与隐私保护",
                content: "AI系统需要大量数据进行训练，这引发了严重的隐私问题。如何在利用数据价值的同时保护个人隐私，是AI发展面临的重要挑战。差分隐私、联邦学习等技术为隐私保护提供了新的解决方案。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI隐私保护的主要挑战是什么？",
                        options: ["计算成本高", "平衡数据价值与隐私保护", "技术复杂", "用户接受度低"],
                        correctAnswer: 1,
                        explanation: "AI隐私保护的主要挑战是平衡数据价值与隐私保护",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI对就业的影响",
                content: "AI技术的快速发展可能对就业市场产生重大影响，某些工作可能被自动化替代，同时也会创造新的就业机会。如何应对这种变化，确保社会的包容性和公平性，是AI伦理的重要议题。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI对就业的影响是什么？",
                        options: ["只会有负面影响", "只会有正面影响", "既有正面也有负面影响", "没有影响"],
                        correctAnswer: 2,
                        explanation: "AI对就业既有正面影响（创造新机会），也有负面影响（替代某些工作）",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI治理与监管",
                content: "随着AI技术的广泛应用，建立有效的治理和监管框架变得越来越重要。这包括技术标准、伦理准则、法律法规等多个层面，需要政府、企业、学术界和公民社会的共同努力。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI治理需要哪些方面的参与？",
                        options: ["只有政府", "只有企业", "政府、企业、学术界和公民社会", "只有学术界"],
                        correctAnswer: 2,
                        explanation: "AI治理需要政府、企业、学术界和公民社会的共同努力",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    // MARK: - 新增课程内容
    
    private func createReinforcementLearningLessons() -> [Lesson] {
        return [
            Lesson(
                title: "强化学习基础",
                content: "强化学习是机器学习的一个分支，智能体通过与环境交互来学习最优策略。它基于奖励机制，智能体通过试错来最大化长期累积奖励。强化学习在游戏AI、机器人控制、自动驾驶等领域有广泛应用。",
                type: .theory,
                questions: [
                    Question(
                        question: "强化学习的核心思想是什么？",
                        options: ["通过试错学习最优策略", "使用标记数据训练", "无监督学习", "深度学习"],
                        correctAnswer: 0,
                        explanation: "强化学习的核心思想是通过试错来学习最优策略，基于奖励机制",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "强化学习中的智能体通过什么来学习？",
                        options: ["标记的训练数据", "与环境的交互", "预定义的规则", "监督信号"],
                        correctAnswer: 1,
                        explanation: "强化学习中的智能体通过与环境的交互来学习",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "Q-Learning算法",
                content: "Q-Learning是强化学习中最经典的算法之一。它通过Q表来存储状态-动作对的价值，通过不断更新Q值来学习最优策略。Q-Learning不需要环境模型，是一种无模型的方法。",
                type: .theory,
                questions: [
                    Question(
                        question: "Q-Learning算法使用什么来存储价值信息？",
                        options: ["神经网络", "Q表", "决策树", "支持向量机"],
                        correctAnswer: 1,
                        explanation: "Q-Learning使用Q表来存储状态-动作对的价值",
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
                content: "大语言模型（LLM）是基于Transformer架构的深度学习模型，能够理解和生成人类语言。GPT、BERT、T5等模型在自然语言处理任务中取得了突破性进展，推动了AI技术的发展。",
                type: .theory,
                questions: [
                    Question(
                        question: "大语言模型主要基于什么架构？",
                        options: ["CNN", "RNN", "Transformer", "GAN"],
                        correctAnswer: 2,
                        explanation: "大语言模型主要基于Transformer架构",
                        type: .multipleChoice
                    ),
                    Question(
                        question: "以下哪个不是著名的大语言模型？",
                        options: ["GPT", "BERT", "ResNet", "T5"],
                        correctAnswer: 2,
                        explanation: "ResNet是计算机视觉领域的模型，不是大语言模型",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "Transformer架构",
                content: "Transformer是一种基于注意力机制的神经网络架构，彻底改变了自然语言处理领域。它通过自注意力机制来捕获序列中的长距离依赖关系，避免了RNN的梯度消失问题。",
                type: .theory,
                questions: [
                    Question(
                        question: "Transformer的核心机制是什么？",
                        options: ["卷积操作", "循环连接", "注意力机制", "池化操作"],
                        correctAnswer: 2,
                        explanation: "Transformer的核心机制是注意力机制",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIHealthcareLessons() -> [Lesson] {
        return [
            Lesson(
                title: "AI在医疗诊断中的应用",
                content: "AI在医疗诊断中发挥着越来越重要的作用，包括医学影像分析、病理诊断、疾病预测等。深度学习模型在X光片、CT扫描、MRI等医学影像的识别准确率已经达到或超过人类专家水平。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI在医疗诊断中的主要应用不包括？",
                        options: ["医学影像分析", "病理诊断", "疾病预测", "药物生产"],
                        correctAnswer: 3,
                        explanation: "药物生产不是AI在医疗诊断中的主要应用",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "AI药物发现",
                content: "AI正在改变药物发现的过程，通过机器学习算法可以预测分子的生物活性、优化药物结构、加速临床试验等。这大大缩短了新药研发的时间和成本。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI在药物发现中的主要优势是什么？",
                        options: ["降低成本", "缩短时间", "提高准确性", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI在药物发现中可以降低成本、缩短时间、提高准确性",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIFintechLessons() -> [Lesson] {
        return [
            Lesson(
                title: "AI在风险评估中的应用",
                content: "AI在金融风险评估中发挥着重要作用，通过分析大量历史数据和实时信息，AI系统可以更准确地评估信用风险、市场风险和操作风险，帮助金融机构做出更好的决策。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI在金融风险评估中的主要优势是什么？",
                        options: ["处理大量数据", "实时分析", "提高准确性", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI在金融风险评估中可以处理大量数据、实时分析、提高准确性",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "智能投顾系统",
                content: "智能投顾（Robo-Advisor）是基于AI技术的自动化投资顾问服务。它可以根据投资者的风险偏好、投资目标和市场情况，自动生成个性化的投资组合建议，并提供持续的投资组合管理。",
                type: .theory,
                questions: [
                    Question(
                        question: "智能投顾系统的主要特点是什么？",
                        options: ["自动化", "个性化", "低成本", "以上都是"],
                        correctAnswer: 3,
                        explanation: "智能投顾系统具有自动化、个性化、低成本等特点",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIEdTechLessons() -> [Lesson] {
        return [
            Lesson(
                title: "个性化学习系统",
                content: "AI驱动的个性化学习系统可以根据每个学生的学习风格、进度和需求，提供定制化的学习内容和路径。这种系统能够提高学习效率，让每个学生都能获得最适合自己的学习体验。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI个性化学习系统的主要优势是什么？",
                        options: ["适应学习风格", "提高学习效率", "定制化内容", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI个性化学习系统可以适应学习风格、提高学习效率、提供定制化内容",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "智能评估系统",
                content: "AI智能评估系统可以自动分析学生的学习表现，提供详细的反馈和建议。它不仅能评估知识掌握程度，还能分析学习过程中的问题，帮助学生改进学习方法。",
                type: .theory,
                questions: [
                    Question(
                        question: "AI智能评估系统可以做什么？",
                        options: ["自动评分", "提供反馈", "分析学习问题", "以上都是"],
                        correctAnswer: 3,
                        explanation: "AI智能评估系统可以自动评分、提供反馈、分析学习问题",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIAutonomousDrivingLessons() -> [Lesson] {
        return [
            Lesson(
                title: "自动驾驶技术基础",
                content: "自动驾驶汽车是AI技术的重要应用领域，它结合了计算机视觉、传感器融合、路径规划等多种AI技术。自动驾驶系统需要实时感知环境、理解交通规则、做出安全决策。",
                type: .theory,
                questions: [
                    Question(
                        question: "自动驾驶汽车主要依赖哪些AI技术？",
                        options: ["计算机视觉", "传感器融合", "路径规划", "以上都是"],
                        correctAnswer: 3,
                        explanation: "自动驾驶汽车依赖计算机视觉、传感器融合、路径规划等多种AI技术",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "环境感知与理解",
                content: "自动驾驶汽车的环境感知系统需要识别道路、车辆、行人、交通标志等，并理解它们的含义和关系。这需要先进的计算机视觉算法和深度学习模型。",
                type: .theory,
                questions: [
                    Question(
                        question: "自动驾驶汽车需要感知哪些环境信息？",
                        options: ["道路状况", "其他车辆", "行人", "以上都是"],
                        correctAnswer: 3,
                        explanation: "自动驾驶汽车需要感知道路状况、其他车辆、行人等环境信息",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
    
    private func createAIGameDevLessons() -> [Lesson] {
        return [
            Lesson(
                title: "游戏AI基础",
                content: "游戏AI是AI技术的重要应用领域，包括角色行为AI、路径寻找、决策制定等。现代游戏AI使用各种算法，从简单的状态机到复杂的机器学习模型，为玩家提供更智能和有趣的游戏体验。",
                type: .theory,
                questions: [
                    Question(
                        question: "游戏AI的主要功能不包括？",
                        options: ["角色行为控制", "路径寻找", "图形渲染", "决策制定"],
                        correctAnswer: 2,
                        explanation: "图形渲染不是游戏AI的主要功能，它是图形学的内容",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            ),
            Lesson(
                title: "程序化内容生成",
                content: "程序化内容生成（PCG）使用AI算法自动生成游戏内容，如关卡、地图、任务等。这可以大大减少游戏开发的工作量，同时为玩家提供无限的游戏内容。",
                type: .theory,
                questions: [
                    Question(
                        question: "程序化内容生成可以生成什么？",
                        options: ["游戏关卡", "游戏地图", "游戏任务", "以上都是"],
                        correctAnswer: 3,
                        explanation: "程序化内容生成可以生成游戏关卡、地图、任务等",
                        type: .multipleChoice
                    )
                ],
                isCompleted: false
            )
        ]
    }
}
