import Foundation
import Combine
import Network
import SwiftUI // Added for SwiftUI

// MARK: - 云端数据同步服务
class CloudSyncService: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    @Published var syncStatus: SyncStatus = .idle
    @Published var syncProgress: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NetworkMonitor()
    private let userDefaults = UserDefaults.standard
    private let offlineQueueKey = "OfflineDataChanges"
    
    // 同步配置
    private var syncConfig = SyncConfig()
    
    init() {
        loadSyncConfig()
        setupNetworkMonitoring()
        setupAutoSync()
    }
    
    // MARK: - 数据同步
    func syncUserData(_ userData: SyncData) async {
        await MainActor.run {
            isSyncing = true
            syncStatus = .syncing
            syncProgress = 0.0
        }
        
        do {
            // 检查网络状态
            guard networkMonitor.isConnected else {
                await queueOfflineChanges(userData)
                await MainActor.run {
                    isSyncing = false
                    syncStatus = .failed("网络连接不可用，数据已加入离线队列")
                }
                return
            }
            
            // 上传本地数据
            await updateProgress(0.3)
            let uploadSuccess = await uploadUserData(userData)
            
            if uploadSuccess {
                // 下载云端数据
                await updateProgress(0.6)
                if let cloudData = await downloadUserData() {
                    // 解决数据冲突
                    await updateProgress(0.8)
                    let resolvedData = resolveDataConflict(localData: userData, cloudData: cloudData)
                    
                    // 应用云端数据到本地
                    await updateProgress(0.9)
                    await applyCloudDataToLocal(resolvedData)
                    
                    await MainActor.run {
                        isSyncing = false
                        syncStatus = .success
                        lastSyncTime = Date()
                        syncProgress = 1.0
                    }
                } else {
                    await MainActor.run {
                        isSyncing = false
                        syncStatus = .failed("下载云端数据失败")
                    }
                }
            } else {
                await MainActor.run {
                    isSyncing = false
                    syncStatus = .failed("上传本地数据失败")
                }
            }
        } catch {
            await MainActor.run {
                isSyncing = false
                syncStatus = .failed("同步错误: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 数据上传
    func uploadUserData(_ userData: SyncData) async -> Bool {
        do {
            // 模拟网络请求延迟
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒
            
            // 在实际应用中，这里会调用真实的云端API
            // 例如：Firebase, AWS, 或自定义的后端服务
            
            // 模拟上传成功率
            let random = Double.random(in: 0...1)
            return random > 0.05 // 95%成功率
        } catch {
            return false
        }
    }
    
    // MARK: - 数据下载
    func downloadUserData() async -> SyncData? {
        do {
            // 模拟数据下载
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
            
            // 模拟下载成功率
            let random = Double.random(in: 0...1)
            if random > 0.1 { // 90%成功率
                // 返回模拟的云端数据
                return createMockCloudData()
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - 冲突解决
    func resolveDataConflict(localData: SyncData, cloudData: SyncData) -> SyncData {
        switch syncConfig.conflictResolution {
        case .latestWins:
            return localData.lastSyncTime > cloudData.lastSyncTime ? localData : cloudData
        case .localWins:
            return localData
        case .cloudWins:
            return cloudData
        case .manual:
            // 在实际应用中，这里会显示冲突解决界面
            return localData.lastSyncTime > cloudData.lastSyncTime ? localData : cloudData
        }
    }
    
    // MARK: - 离线支持
    func queueOfflineChanges(_ userData: SyncData) async {
        let change = DataChange(
            type: .update,
            entityId: UUID(),
            entityType: .userProgress,
            timestamp: Date(),
            data: try! JSONEncoder().encode(userData)
        )
        
        var offlineQueue = getOfflineQueue()
        offlineQueue.append(change)
        saveOfflineQueue(offlineQueue)
    }
    
    func processOfflineQueue() async {
        let offlineQueue = getOfflineQueue()
        guard !offlineQueue.isEmpty else { return }
        
        await MainActor.run {
            syncStatus = .syncing
            syncProgress = 0.0
        }
        
        for (index, change) in offlineQueue.enumerated() {
            // 处理每个离线更改
            let success = await processOfflineChange(change)
            
            if success {
                // 从队列中移除成功的更改
                var updatedQueue = offlineQueue
                updatedQueue.remove(at: index)
                saveOfflineQueue(updatedQueue)
            }
            
            await updateProgress(Double(index + 1) / Double(offlineQueue.count))
        }
        
        await MainActor.run {
            syncStatus = .success
            syncProgress = 1.0
        }
    }
    
    private func processOfflineChange(_ change: DataChange) async -> Bool {
        // 模拟处理离线更改
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
        return Double.random(in: 0...1) > 0.1 // 90%成功率
    }
    
    // MARK: - 本地数据管理
    private func applyCloudDataToLocal(_ cloudData: SyncData) async {
        // 将云端数据应用到本地
        // 这里需要根据实际的数据存储方式来实现
        
        // 更新用户进度
        if let encoded = try? JSONEncoder().encode(cloudData.userProgress) {
            userDefaults.set(encoded, forKey: "UserProgress")
        }
        
        // 更新学习计划
        if let encoded = try? JSONEncoder().encode(cloudData.studyPlans) {
            userDefaults.set(encoded, forKey: "StudyPlans")
        }
        
        // 更新社交数据
        if let encoded = try? JSONEncoder().encode(cloudData.studyGroups) {
            userDefaults.set(encoded, forKey: "StudyGroups")
        }
        
        if let encoded = try? JSONEncoder().encode(cloudData.studyPosts) {
            userDefaults.set(encoded, forKey: "CommunityPosts")
        }
        
        // 更新AI聊天会话
        if let encoded = try? JSONEncoder().encode(cloudData.chatSessions) {
            userDefaults.set(encoded, forKey: "ChatSessions")
        }
    }
    
    // MARK: - 离线队列管理
    private func getOfflineQueue() -> [DataChange] {
        if let data = userDefaults.data(forKey: offlineQueueKey),
           let queue = try? JSONDecoder().decode([DataChange].self, from: data) {
            return queue
        }
        return []
    }
    
    private func saveOfflineQueue(_ queue: [DataChange]) {
        if let encoded = try? JSONEncoder().encode(queue) {
            userDefaults.set(encoded, forKey: offlineQueueKey)
        }
    }
    
    // MARK: - 同步配置管理
    private func loadSyncConfig() {
        if let data = userDefaults.data(forKey: "SyncConfig"),
           let config = try? JSONDecoder().decode(SyncConfig.self, from: data) {
            syncConfig = config
        }
    }
    
    func updateSyncConfig(_ config: SyncConfig) {
        syncConfig = config
        if let encoded = try? JSONEncoder().encode(config) {
            userDefaults.set(encoded, forKey: "SyncConfig")
        }
    }
    
    // MARK: - 自动同步设置
    private func setupAutoSync() {
        guard syncConfig.autoSyncEnabled else { return }
        
        Timer.publish(every: syncConfig.syncInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.performAutoSync()
                }
            }
            .store(in: &cancellables)
    }
    
    private func performAutoSync() async {
        // 检查是否只在WiFi下同步
        if syncConfig.wifiOnly && networkMonitor.connectionType != .wifi {
            return
        }
        
        // 创建当前数据的快照
        let currentData = await createCurrentDataSnapshot()
        await syncUserData(currentData)
    }
    
    private func createCurrentDataSnapshot() async -> SyncData {
        // 从本地存储创建当前数据的快照
        // 这里需要根据实际的数据存储方式来实现
        
        let userProgress = UserProgress()
        let studyPlans: [StudyPlan] = []
        let chatSessions: [ChatSession] = []
        let studyGroups: [StudyGroup] = []
        let studyPosts: [StudyPost] = []
        
        return SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: userProgress,
            studyPlans: studyPlans,
            chatSessions: chatSessions,
            studyGroups: studyGroups,
            studyPosts: studyPosts
        )
    }
    
    // MARK: - 网络监控设置
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    // 网络恢复时，处理离线队列
                    Task {
                        await self?.processOfflineQueue()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 进度更新
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            syncProgress = progress
        }
    }
    
    // MARK: - 同步状态管理
    func resetSyncStatus() {
        syncStatus = .idle
        syncProgress = 0.0
    }
    
    func getSyncProgress() -> Double {
        return syncProgress
    }
    
    // MARK: - 辅助方法
    private func createMockCloudData() -> SyncData {
        // 创建模拟的云端数据用于测试
        let mockProgress = UserProgress()
        let mockPlans: [StudyPlan] = []
        let mockChatSessions: [ChatSession] = []
        let mockGroups: [StudyGroup] = []
        let mockPosts: [StudyPost] = []
        
        return SyncData(
            userId: "cloud_user_123",
            lastSyncTime: Date(),
            userProgress: mockProgress,
            studyPlans: mockPlans,
            chatSessions: mockChatSessions,
            studyGroups: mockGroups,
            studyPosts: mockPosts
        )
    }
}

// MARK: - 数据更改模型
struct DataChange: Identifiable, Codable {
    let id = UUID()
    let type: ChangeType
    let entityId: UUID
    let entityType: EntityType
    let timestamp: Date
    let data: Data // 序列化后的数据
    
    enum ChangeType: String, Codable {
        case create
        case update
        case delete
    }
    
    enum EntityType: String, Codable {
        case userProgress
        case studyPlan
        case chatSession
        case studyGroup
        case studyPost
    }
}

// MARK: - 同步配置
struct SyncConfig: Codable {
    var autoSyncEnabled: Bool = true
    var syncInterval: TimeInterval = 300 // 5分钟
    var wifiOnly: Bool = false
    var conflictResolution: ConflictResolution = .latestWins
    
    enum ConflictResolution: String, Codable {
        case latestWins = "latest"
        case localWins = "local"
        case cloudWins = "cloud"
        case manual = "manual"
    }
}

// MARK: - 网络状态监控
class NetworkMonitor: ObservableObject {
    @Published var isConnected = true
    @Published var connectionType: ConnectionType = .wifi
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case none
    }
    
    init() {
        startMonitoring()
    }
    
    deinit {
        stopMonitoring()
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.updateConnectionStatus(path)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func updateConnectionStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .none
        }
    }
}

// MARK: - 云端同步设置视图
struct CloudSyncSettingsView: View {
    @StateObject private var cloudSyncService = CloudSyncService()
    @State private var syncConfig = SyncConfig()
    @State private var showingSyncStatus = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("同步设置")) {
                    Toggle("启用自动同步", isOn: $syncConfig.autoSyncEnabled)
                    
                    if syncConfig.autoSyncEnabled {
                        HStack {
                            Text("同步间隔")
                            Spacer()
                            Picker("同步间隔", selection: $syncConfig.syncInterval) {
                                Text("1分钟").tag(TimeInterval(60))
                                Text("5分钟").tag(TimeInterval(300))
                                Text("15分钟").tag(TimeInterval(900))
                                Text("30分钟").tag(TimeInterval(1800))
                                Text("1小时").tag(TimeInterval(3600))
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        Toggle("仅WiFi同步", isOn: $syncConfig.wifiOnly)
                    }
                }
                
                Section(header: Text("冲突解决")) {
                    Picker("冲突解决策略", selection: $syncConfig.conflictResolution) {
                        Text("最新优先").tag(SyncConfig.ConflictResolution.latestWins)
                        Text("本地优先").tag(SyncConfig.ConflictResolution.localWins)
                        Text("云端优先").tag(SyncConfig.ConflictResolution.cloudWins)
                        Text("手动解决").tag(SyncConfig.ConflictResolution.manual)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("同步状态")) {
                    HStack {
                        Text("状态")
                        Spacer()
                        Text(syncStatusText)
                            .foregroundColor(syncStatusColor)
                    }
                    
                    if let lastSync = cloudSyncService.lastSyncTime {
                        HStack {
                            Text("上次同步")
                            Spacer()
                            Text(lastSync, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if cloudSyncService.isSyncing {
                        HStack {
                            Text("同步进度")
                            Spacer()
                            ProgressView(value: cloudSyncService.syncProgress)
                                .frame(width: 100)
                        }
                    }
                }
                
                Section {
                    Button(action: {
                        Task {
                            await performManualSync()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("立即同步")
                        }
                    }
                    .disabled(cloudSyncService.isSyncing)
                    
                    Button(action: {
                        cloudSyncService.resetSyncStatus()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("重置状态")
                        }
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("云端同步")
            .onAppear {
                loadCurrentConfig()
            }
            .onChange(of: syncConfig) { newConfig in
                cloudSyncService.updateSyncConfig(newConfig)
            }
        }
    }
    
    private var syncStatusText: String {
        switch cloudSyncService.syncStatus {
        case .idle:
            return "空闲"
        case .syncing:
            return "同步中"
        case .success:
            return "成功"
        case .failed(let error):
            return "失败: \(error)"
        }
    }
    
    private var syncStatusColor: Color {
        switch cloudSyncService.syncStatus {
        case .idle:
            return .secondary
        case .syncing:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }
    
    private func loadCurrentConfig() {
        // 从UserDefaults加载当前配置
        if let data = UserDefaults.standard.data(forKey: "SyncConfig"),
           let config = try? JSONDecoder().decode(SyncConfig.self, from: data) {
            syncConfig = config
        }
    }
    
    private func performManualSync() async {
        // 创建当前数据的快照
        let currentData = await createCurrentDataSnapshot()
        await cloudSyncService.syncUserData(currentData)
    }
    
    private func createCurrentDataSnapshot() async -> SyncData {
        // 从本地存储创建当前数据的快照
        let userProgress = UserProgress()
        let studyPlans: [StudyPlan] = []
        let chatSessions: [ChatSession] = []
        let studyGroups: [StudyGroup] = []
        let studyPosts: [StudyPost] = []
        
        return SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: userProgress,
            studyPlans: studyPlans,
            chatSessions: chatSessions,
            studyGroups: studyGroups,
            studyPosts: studyPosts
        )
    }
}

// MARK: - 同步状态指示器
struct SyncStatusIndicator: View {
    @ObservedObject var cloudSyncService: CloudSyncService
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(syncStatusColor)
                .frame(width: 8, height: 8)
            
            if cloudSyncService.isSyncing {
                ProgressView()
                    .scaleEffect(0.7)
            }
            
            Text(syncStatusText)
                .font(.caption)
                .foregroundColor(syncStatusColor)
        }
    }
    
    private var syncStatusText: String {
        switch cloudSyncService.syncStatus {
        case .idle:
            return "已同步"
        case .syncing:
            return "同步中"
        case .success:
            return "同步成功"
        case .failed:
            return "同步失败"
        }
    }
    
    private var syncStatusColor: Color {
        switch cloudSyncService.syncStatus {
        case .idle:
            return .green
        case .syncing:
            return .blue
        case .success:
            return .green
        case .failed:
            return .red
        }
    }
}

// MARK: - 云端同步管理器
class CloudSyncManager: ObservableObject {
    @Published var isInitialized = false
    @Published var syncError: String?
    
    private let cloudSyncService = CloudSyncService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSyncManager()
    }
    
    // MARK: - 初始化同步管理器
    private func setupSyncManager() {
        // 监听同步状态变化
        cloudSyncService.$syncStatus
            .sink { [weak self] status in
                DispatchQueue.main.async {
                    self?.handleSyncStatusChange(status)
                }
            }
            .store(in: &cancellables)
        
        // 监听网络状态变化
        cloudSyncService.networkMonitor.$isConnected
            .sink { [weak self] isConnected in
                if isConnected {
                    Task {
                        await self?.handleNetworkReconnection()
                    }
                }
            }
            .store(in: &cancellables)
        
        isInitialized = true
    }
    
    // MARK: - 同步所有数据
    func syncAllData() async {
        let allData = await collectAllLocalData()
        await cloudSyncService.syncUserData(allData)
    }
    
    // MARK: - 同步特定类型数据
    func syncUserProgress() async {
        let userProgress = UserProgress()
        let syncData = SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: userProgress,
            studyPlans: [],
            chatSessions: [],
            studyGroups: [],
            studyPosts: []
        )
        await cloudSyncService.syncUserData(syncData)
    }
    
    func syncStudyPlans() async {
        // 从本地存储加载学习计划
        let studyPlans: [StudyPlan] = []
        let syncData = SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: UserProgress(),
            studyPlans: studyPlans,
            chatSessions: [],
            studyGroups: [],
            studyPosts: []
        )
        await cloudSyncService.syncUserData(syncData)
    }
    
    func syncSocialData() async {
        // 从本地存储加载社交数据
        let studyGroups: [StudyGroup] = []
        let studyPosts: [StudyPost] = []
        let syncData = SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: UserProgress(),
            studyPlans: [],
            chatSessions: [],
            studyGroups: studyGroups,
            studyPosts: studyPosts
        )
        await cloudSyncService.syncUserData(syncData)
    }
    
    func syncAIChatData() async {
        // 从本地存储加载AI聊天数据
        let chatSessions: [ChatSession] = []
        let syncData = SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: UserProgress(),
            studyPlans: [],
            chatSessions: chatSessions,
            studyGroups: [],
            studyPosts: []
        )
        await cloudSyncService.syncUserData(syncData)
    }
    
    // MARK: - 数据收集
    private func collectAllLocalData() async -> SyncData {
        // 从本地存储收集所有数据
        let userProgress = UserProgress()
        let studyPlans: [StudyPlan] = []
        let chatSessions: [ChatSession] = []
        let studyGroups: [StudyGroup] = []
        let studyPosts: [StudyPost] = []
        
        return SyncData(
            userId: "local_user",
            lastSyncTime: Date(),
            userProgress: userProgress,
            studyPlans: studyPlans,
            chatSessions: chatSessions,
            studyGroups: studyGroups,
            studyPosts: studyPosts
        )
    }
    
    // MARK: - 状态处理
    private func handleSyncStatusChange(_ status: CloudSyncService.SyncStatus) {
        switch status {
        case .failed(let error):
            syncError = error
        case .success:
            syncError = nil
        default:
            break
        }
    }
    
    private func handleNetworkReconnection() async {
        // 网络恢复时，处理离线队列
        await cloudSyncService.processOfflineQueue()
    }
    
    // MARK: - 公共接口
    var cloudSyncService: CloudSyncService {
        return self.cloudSyncService
    }
    
    func clearSyncError() {
        syncError = nil
    }
    
    func getSyncStatus() -> CloudSyncService.SyncStatus {
        return cloudSyncService.syncStatus
    }
    
    func isSyncing() -> Bool {
        return cloudSyncService.isSyncing
    }
    
    func getSyncProgress() -> Double {
        return cloudSyncService.syncProgress
    }
}

// MARK: - 同步状态扩展
extension CloudSyncService.SyncStatus: Equatable {
    static func == (lhs: CloudSyncService.SyncStatus, rhs: CloudSyncService.SyncStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.syncing, .syncing):
            return true
        case (.success, .success):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

// MARK: - 云端同步集成示例
struct CloudSyncIntegrationExample: View {
    @StateObject private var cloudSyncManager = CloudSyncManager()
    @State private var showingSyncSettings = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("同步状态")) {
                    HStack {
                        Text("状态")
                        Spacer()
                        SyncStatusIndicator(cloudSyncService: cloudSyncManager.cloudSyncService)
                    }
                    
                    if let error = cloudSyncManager.syncError {
                        HStack {
                            Text("错误")
                            Spacer()
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section(header: Text("同步操作")) {
                    Button("同步所有数据") {
                        Task {
                            await cloudSyncManager.syncAllData()
                        }
                    }
                    .disabled(cloudSyncManager.isSyncing())
                    
                    Button("同步用户进度") {
                        Task {
                            await cloudSyncManager.syncUserProgress()
                        }
                    }
                    .disabled(cloudSyncManager.isSyncing())
                    
                    Button("同步学习计划") {
                        Task {
                            await cloudSyncManager.syncStudyPlans()
                        }
                    }
                    .disabled(cloudSyncManager.isSyncing())
                    
                    Button("同步社交数据") {
                        Task {
                            await cloudSyncManager.syncSocialData()
                        }
                    }
                    .disabled(cloudSyncManager.isSyncing())
                    
                    Button("同步AI聊天数据") {
                        Task {
                            await cloudSyncManager.syncAIChatData()
                        }
                    }
                    .disabled(cloudSyncManager.isSyncing())
                }
                
                Section(header: Text("设置")) {
                    Button("同步设置") {
                        showingSyncSettings = true
                    }
                }
            }
            .navigationTitle("云端同步")
            .sheet(isPresented: $showingSyncSettings) {
                CloudSyncSettingsView()
            }
            .alert("同步错误", isPresented: .constant(cloudSyncManager.syncError != nil)) {
                Button("确定") {
                    cloudSyncManager.clearSyncError()
                }
            } message: {
                if let error = cloudSyncManager.syncError {
                    Text(error)
                }
            }
        }
    }
}

// MARK: - 在现有视图中添加同步状态指示器的示例
struct SyncStatusBar: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        HStack {
            SyncStatusIndicator(cloudSyncService: cloudSyncManager.cloudSyncService)
            
            Spacer()
            
            if cloudSyncManager.isSyncing() {
                ProgressView(value: cloudSyncManager.getSyncProgress())
                    .frame(width: 100)
            }
            
            Button("同步") {
                Task {
                    await cloudSyncManager.syncAllData()
                }
            }
            .disabled(cloudSyncManager.isSyncing())
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

// MARK: - 云端同步使用说明
/*
 
 使用方法：
 
 1. 在需要同步数据的视图中添加 CloudSyncManager：
    @StateObject private var cloudSyncManager = CloudSyncManager()
 
 2. 在适当的时候调用同步方法：
    Task {
        await cloudSyncManager.syncAllData()
    }
 
 3. 在UI中显示同步状态：
    SyncStatusIndicator(cloudSyncService: cloudSyncManager.cloudSyncService)
 
 4. 处理同步错误：
    if let error = cloudSyncManager.syncError {
        // 显示错误信息
    }
 
 5. 配置同步选项：
    CloudSyncSettingsView()
 
 主要特性：
 - 自动同步：可配置的定时同步
 - 离线支持：网络断开时数据加入队列
 - 冲突解决：多种冲突解决策略
 - 网络监控：实时网络状态检测
 - 进度跟踪：同步进度显示
 - 错误处理：完善的错误处理机制
 
 */

// MARK: - 云端服务配置
struct CloudServiceConfig: Codable {
    let serviceType: CloudServiceType
    let apiKey: String
    let baseURL: String
    let timeout: TimeInterval
    let retryCount: Int
    
    enum CloudServiceType: String, CaseIterable, Codable {
        case firebase = "Firebase"
        case aws = "AWS"
        case azure = "Azure"
        case custom = "自定义"
        
        var description: String {
            switch self {
            case .firebase: return "Firebase (Google)"
            case .aws: return "AWS (Amazon)"
            case .azure: return "Azure (Microsoft)"
            case .custom: return "自定义服务"
            }
        }
    }
    
    init(serviceType: CloudServiceType, apiKey: String, baseURL: String, timeout: TimeInterval = 30, retryCount: Int = 3) {
        self.serviceType = serviceType
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.timeout = timeout
        self.retryCount = retryCount
    }
}

// MARK: - 云端服务接口
protocol CloudServiceProtocol {
    func uploadData(_ data: Data, path: String) async throws -> Bool
    func downloadData(path: String) async throws -> Data?
    func deleteData(path: String) async throws -> Bool
    func listData(path: String) async throws -> [String]
}

// MARK: - Firebase服务实现
class FirebaseService: CloudServiceProtocol {
    private let config: CloudServiceConfig
    
    init(config: CloudServiceConfig) {
        self.config = config
    }
    
    func uploadData(_ data: Data, path: String) async throws -> Bool {
        // 模拟Firebase上传
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Double.random(in: 0...1) > 0.05
    }
    
    func downloadData(path: String) async throws -> Data? {
        // 模拟Firebase下载
        try await Task.sleep(nanoseconds: 800_000_000)
        if Double.random(in: 0...1) > 0.1 {
            return Data() // 返回模拟数据
        }
        return nil
    }
    
    func deleteData(path: String) async throws -> Bool {
        // 模拟Firebase删除
        try await Task.sleep(nanoseconds: 500_000_000)
        return Double.random(in: 0...1) > 0.05
    }
    
    func listData(path: String) async throws -> [String] {
        // 模拟Firebase列表
        try await Task.sleep(nanoseconds: 600_000_000)
        return ["data1", "data2", "data3"]
    }
}

// MARK: - AWS服务实现
class AWSService: CloudServiceProtocol {
    private let config: CloudServiceConfig
    
    init(config: CloudServiceConfig) {
        self.config = config
    }
    
    func uploadData(_ data: Data, path: String) async throws -> Bool {
        // 模拟AWS上传
        try await Task.sleep(nanoseconds: 1_200_000_000)
        return Double.random(in: 0...1) > 0.05
    }
    
    func downloadData(path: String) async throws -> Data? {
        // 模拟AWS下载
        try await Task.sleep(nanoseconds: 1_000_000_000)
        if Double.random(in: 0...1) > 0.1 {
            return Data() // 返回模拟数据
        }
        return nil
    }
    
    func deleteData(path: String) async throws -> Bool {
        // 模拟AWS删除
        try await Task.sleep(nanoseconds: 600_000_000)
        return Double.random(in: 0...1) > 0.05
    }
    
    func listData(path: String) async throws -> [String] {
        // 模拟AWS列表
        try await Task.sleep(nanoseconds: 700_000_000)
        return ["aws_data1", "aws_data2", "aws_data3"]
    }
}

// MARK: - 云端服务工厂
class CloudServiceFactory {
    static func createService(for config: CloudServiceConfig) -> CloudServiceProtocol {
        switch config.serviceType {
        case .firebase:
            return FirebaseService(config: config)
        case .aws:
            return AWSService(config: config)
        case .azure:
            // 实现Azure服务
            return FirebaseService(config: config) // 临时使用Firebase
        case .custom:
            // 实现自定义服务
            return FirebaseService(config: config) // 临时使用Firebase
        }
    }
}

// MARK: - 云端同步配置视图
struct CloudServiceConfigView: View {
    @State private var config = CloudServiceConfig(
        serviceType: .firebase,
        apiKey: "",
        baseURL: "",
        timeout: 30,
        retryCount: 3
    )
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("服务类型")) {
                    Picker("云端服务", selection: $config.serviceType) {
                        ForEach(CloudServiceConfig.CloudServiceType.allCases, id: \.self) { type in
                            Text(type.description).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("连接配置")) {
                    TextField("API密钥", text: $config.apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("基础URL", text: $config.baseURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("高级设置")) {
                    HStack {
                        Text("超时时间")
                        Spacer()
                        Text("\(Int(config.timeout))秒")
                    }
                    
                    Slider(value: $config.timeout, in: 10...60, step: 5)
                    
                    HStack {
                        Text("重试次数")
                        Spacer()
                        Text("\(config.retryCount)")
                    }
                    
                    Stepper("", value: $config.retryCount, in: 1...5)
                }
                
                Section {
                    Button("测试连接") {
                        testConnection()
                    }
                    .foregroundColor(.blue)
                    
                    Button("保存配置") {
                        saveConfig()
                    }
                    .foregroundColor(.green)
                }
            }
            .navigationTitle("云端服务配置")
            .alert("配置结果", isPresented: $showingAlert) {
                Button("确定") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func testConnection() {
        let service = CloudServiceFactory.createService(for: config)
        
        Task {
            do {
                let result = try await service.uploadData(Data(), path: "test")
                await MainActor.run {
                    alertMessage = result ? "连接测试成功" : "连接测试失败"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertMessage = "连接测试错误: \(error.localizedDescription)"
                    showingAlert = true
                }
            }
        }
    }
    
    private func saveConfig() {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: "CloudServiceConfig")
            alertMessage = "配置已保存"
            showingAlert = true
        } else {
            alertMessage = "保存配置失败"
            showingAlert = true
        }
    }
}

// MARK: - 云端同步功能演示视图
struct CloudSyncDemoView: View {
    @StateObject private var cloudSyncManager = CloudSyncManager()
    @State private var showingSettings = false
    @State private var showingServiceConfig = false
    @State private var selectedDemo: DemoType = .overview
    
    enum DemoType: String, CaseIterable {
        case overview = "功能概览"
        case sync = "数据同步"
        case offline = "离线支持"
        case conflict = "冲突解决"
        case settings = "同步设置"
        case service = "服务配置"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部状态栏
                SyncStatusBar(cloudSyncManager: cloudSyncManager)
                
                // 标签页选择
                Picker("演示类型", selection: $selectedDemo) {
                    ForEach(DemoType.allCases, id: \.self) { demo in
                        Text(demo.rawValue).tag(demo)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                // 内容区域
                TabView(selection: $selectedDemo) {
                    OverviewDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.overview)
                    
                    SyncDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.sync)
                    
                    OfflineDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.offline)
                    
                    ConflictDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.conflict)
                    
                    SettingsDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.settings)
                    
                    ServiceConfigDemoView(cloudSyncManager: cloudSyncManager)
                        .tag(DemoType.service)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("云端同步演示")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("设置") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            CloudSyncSettingsView()
        }
    }
}

// MARK: - 功能概览演示
struct OverviewDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 功能特性卡片
                FeatureCard(
                    icon: "icloud.and.arrow.up",
                    title: "云端同步",
                    description: "支持多设备数据同步，确保学习进度不丢失",
                    color: .blue
                )
                
                FeatureCard(
                    icon: "wifi.slash",
                    title: "离线支持",
                    description: "网络断开时数据变更自动加入队列，网络恢复后自动同步",
                    color: .green
                )
                
                FeatureCard(
                    icon: "exclamationmark.triangle",
                    title: "冲突解决",
                    description: "智能处理多设备数据冲突，支持多种解决策略",
                    color: .orange
                )
                
                FeatureCard(
                    icon: "gear",
                    title: "灵活配置",
                    description: "支持多种云端服务，可配置同步策略和频率",
                    color: .purple
                )
                
                // 状态信息
                StatusInfoView(cloudSyncManager: cloudSyncManager)
            }
            .padding()
        }
    }
}

// MARK: - 数据同步演示
struct SyncDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 同步操作
                VStack(spacing: 16) {
                    Text("数据同步操作")
                        .font(.headline)
                    
                    Button("同步所有数据") {
                        Task {
                            await cloudSyncManager.syncAllData()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(cloudSyncManager.isSyncing())
                    
                    HStack(spacing: 16) {
                        Button("同步进度") {
                            Task {
                                await cloudSyncManager.syncUserProgress()
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(cloudSyncManager.isSyncing())
                        
                        Button("同步计划") {
                            Task {
                                await cloudSyncManager.syncStudyPlans()
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(cloudSyncManager.isSyncing())
                    }
                    
                    HStack(spacing: 16) {
                        Button("同步社交") {
                            Task {
                                await cloudSyncManager.syncSocialData()
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(cloudSyncManager.isSyncing())
                        
                        Button("同步聊天") {
                            Task {
                                await cloudSyncManager.syncAIChatData()
                            }
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(cloudSyncManager.isSyncing())
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 同步状态
                SyncStatusCard(cloudSyncManager: cloudSyncManager)
            }
            .padding()
        }
    }
}

// MARK: - 离线支持演示
struct OfflineDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    @State private var isOffline = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 离线状态模拟
                VStack(spacing: 16) {
                    Text("离线状态模拟")
                        .font(.headline)
                    
                    Toggle("模拟离线状态", isOn: $isOffline)
                        .onChange(of: isOffline) { offline in
                            // 这里可以模拟网络状态变化
                        }
                    
                    if isOffline {
                        Text("当前处于离线状态，数据变更将加入离线队列")
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 离线队列信息
                OfflineQueueInfoView(cloudSyncManager: cloudSyncManager)
                
                // 网络状态
                NetworkStatusView(cloudSyncManager: cloudSyncManager)
            }
            .padding()
        }
    }
}

// MARK: - 冲突解决演示
struct ConflictDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    @State private var selectedStrategy: SyncConfig.ConflictResolution = .latestWins
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 冲突解决策略
                VStack(spacing: 16) {
                    Text("冲突解决策略")
                        .font(.headline)
                    
                    Picker("解决策略", selection: $selectedStrategy) {
                        Text("最新优先").tag(SyncConfig.ConflictResolution.latestWins)
                        Text("本地优先").tag(SyncConfig.ConflictResolution.localWins)
                        Text("云端优先").tag(SyncConfig.ConflictResolution.cloudWins)
                        Text("手动解决").tag(SyncConfig.ConflictResolution.manual)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text("选择数据冲突时的解决策略")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // 冲突示例
                ConflictExampleView()
            }
            .padding()
        }
    }
}

// MARK: - 同步设置演示
struct SettingsDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        CloudSyncSettingsView()
    }
}

// MARK: - 服务配置演示
struct ServiceConfigDemoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        CloudServiceConfigView()
    }
}

// MARK: - 辅助视图
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatusInfoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("当前状态")
                .font(.headline)
            
            HStack {
                Text("同步状态")
                Spacer()
                SyncStatusIndicator(cloudSyncService: cloudSyncManager.cloudSyncService)
            }
            
            if let error = cloudSyncManager.syncError {
                HStack {
                    Text("错误信息")
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SyncStatusCard: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("同步状态")
                .font(.headline)
            
            HStack {
                Text("状态")
                Spacer()
                Text(syncStatusText)
                    .foregroundColor(syncStatusColor)
            }
            
            if cloudSyncManager.isSyncing() {
                HStack {
                    Text("进度")
                    Spacer()
                    ProgressView(value: cloudSyncManager.getSyncProgress())
                        .frame(width: 100)
                }
            }
            
            if let lastSync = cloudSyncManager.cloudSyncService.lastSyncTime {
                HStack {
                    Text("上次同步")
                    Spacer()
                    Text(lastSync, style: .relative)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var syncStatusText: String {
        switch cloudSyncManager.getSyncStatus() {
        case .idle: return "空闲"
        case .syncing: return "同步中"
        case .success: return "成功"
        case .failed: return "失败"
        }
    }
    
    private var syncStatusColor: Color {
        switch cloudSyncManager.getSyncStatus() {
        case .idle: return .secondary
        case .syncing: return .blue
        case .success: return .green
        case .failed: return .red
        }
    }
}

struct OfflineQueueInfoView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("离线队列信息")
                .font(.headline)
            
            Text("离线队列中的更改将在网络恢复后自动同步")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("处理离线队列") {
                Task {
                    await cloudSyncManager.cloudSyncService.processOfflineQueue()
                }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NetworkStatusView: View {
    @ObservedObject var cloudSyncManager: CloudSyncManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("网络状态")
                .font(.headline)
            
            HStack {
                Text("连接状态")
                Spacer()
                Text(cloudSyncManager.cloudSyncService.networkMonitor.isConnected ? "已连接" : "未连接")
                    .foregroundColor(cloudSyncManager.cloudSyncService.networkMonitor.isConnected ? .green : .red)
            }
            
            HStack {
                Text("连接类型")
                Spacer()
                Text(connectionTypeText)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var connectionTypeText: String {
        switch cloudSyncManager.cloudSyncService.networkMonitor.connectionType {
        case .wifi: return "WiFi"
        case .cellular: return "蜂窝网络"
        case .ethernet: return "以太网"
        case .none: return "无连接"
        }
    }
}

struct ConflictExampleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("冲突示例")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("场景：用户在手机和iPad上同时学习")
                Text("• 手机完成课程A，获得10经验")
                Text("• iPad完成课程B，获得15经验")
                Text("• 同步时发现数据冲突")
                Text("• 根据策略自动解决或提示用户选择")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - 按钮样式
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
