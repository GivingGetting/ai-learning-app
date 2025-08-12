#!/bin/bash

# AI Learning iOS App - 云端开发环境设置脚本
# 适用于 GitHub Codespaces 和其他云端开发环境

echo "🚀 正在设置AI学习iOS应用的云端开发环境..."

# 更新系统包
echo "📦 更新系统包..."
sudo apt update && sudo apt upgrade -y

# 安装基础开发工具
echo "🔧 安装基础开发工具..."
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    pkg-config \
    libssl-dev \
    libffi-dev \
    python3 \
    python3-pip \
    nodejs \
    npm

# 安装Swift（如果尚未安装）
if ! command -v swift &> /dev/null; then
    echo "⚡ 安装Swift..."
    wget -qO- https://swift.org/keys/all-keys.asc | gpg --import -
    wget https://swift.org/builds/swift-5.9-release/ubuntu2204/swift-5.9-RELEASE/swift-5.9-RELEASE-ubuntu22.04.tar.gz
    tar xzf swift-5.9-RELEASE-ubuntu22.04.tar.gz
    sudo mv swift-5.9-RELEASE-ubuntu22.04 /usr/share/swift
    echo 'export PATH=/usr/share/swift/usr/bin:$PATH' >> ~/.bashrc
    export PATH=/usr/share/swift/usr/bin:$PATH
    rm swift-5.9-RELEASE-ubuntu22.04.tar.gz
else
    echo "✅ Swift已安装: $(swift --version | head -n1)"
fi

# 安装iOS开发相关工具
echo "📱 安装iOS开发工具..."
sudo apt install -y \
    libxml2-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev

# 安装Swift Package Manager依赖
echo "📚 安装Swift包依赖..."
if [ -f "Package.swift" ]; then
    swift package resolve
    echo "✅ Swift包依赖已安装"
else
    echo "ℹ️  未找到Package.swift文件"
fi

# 创建开发环境配置文件
echo "⚙️  创建开发环境配置..."
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
    "swift.path": "/usr/bin/swift",
    "swift.buildPath": "./.build",
    "swift.targetBuildPath": "./.build/debug",
    "files.associations": {
        "*.swift": "swift"
    },
    "editor.formatOnSave": true,
    "editor.rulers": [120],
    "files.trimTrailingWhitespace": true
}
EOF

# 创建SwiftLint配置（可选）
echo "🔍 配置代码质量检查..."
cat > .swiftlint.yml << EOF
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - force_unwrapping
  - implicitly_unwrapped_optional

excluded:
  - .build
  - .git
  - .swiftpm

line_length:
  warning: 120
  error: 150

function_body_length:
  warning: 50
  error: 100

type_body_length:
  warning: 300
  error: 500
EOF

# 设置Git配置
echo "🔧 配置Git..."
git config --global user.name "AI Learning Developer"
git config --global user.email "developer@ai-learning.app"
git config --global init.defaultBranch main

# 验证环境
echo "✅ 环境验证..."
echo "Swift版本: $(swift --version | head -n1)"
echo "Git版本: $(git --version)"
echo "Node版本: $(node --version)"
echo "NPM版本: $(npm --version)"

# 创建快速启动脚本
echo "🚀 创建快速启动脚本..."
cat > start-dev.sh << 'EOF'
#!/bin/bash
echo "🚀 启动AI学习iOS应用开发环境..."
echo "📱 项目结构:"
tree -I '.git|.build|.swiftpm' -L 2

echo ""
echo "🔧 可用命令:"
echo "  swift build          - 构建项目"
echo "  swift run            - 运行项目"
echo "  swift test           - 运行测试"
echo "  swift package resolve - 解析依赖"
echo "  git status           - 查看Git状态"
echo "  code .               - 在VS Code中打开项目"
EOF

chmod +x start-dev.sh

echo ""
echo "🎉 云端开发环境设置完成！"
echo ""
echo "📋 下一步操作:"
echo "1. 运行 './start-dev.sh' 查看项目状态"
echo "2. 使用 'swift build' 构建项目"
echo "3. 在VS Code中打开项目进行开发"
echo ""
echo "🔗 有用的链接:"
echo "- Swift官方文档: https://swift.org/documentation/"
echo "- SwiftUI指南: https://developer.apple.com/tutorials/swiftui"
echo "- GitHub Codespaces: https://github.com/codespaces"
echo ""
echo "💡 提示: 在Codespaces中，您可以直接在浏览器中进行iOS开发！"
