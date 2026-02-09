import SpriteKit

class EnemyManager {
    
    // MARK: - Properties
    weak var scene: GameScene?
    weak var bulletManager: BulletManager?
    
    // Active enemies array
    private var allEnemies: [Enemy] = []
    
    // Level tracking - Star System
    private var levelTotal: Int = 0
    private var levelKilled: Int = 0
    private var levelEscaped: Int = 0
    private var levelCompletion: ((Int) -> Void)?
    private var trackedEnemies = Set<ObjectIdentifier>()
    
    // Debug information
    private var spawnedCount: Int = 0
    
    // MARK: - Initialization
    init(scene: GameScene, bulletManager: BulletManager) {
        self.scene = scene
        self.bulletManager = bulletManager
    }
    
    // MARK: - Level-Based Enemy Spawning
    func spawnEnemies(for config: LevelManager.LevelConfig, completion: @escaping (Int) -> Void) {
        guard let scene = scene else { return }
        
        print("📋 Starting level with config: \(config.enemies)")
        
        resetLevelData()
        levelCompletion = completion
        
        let enemiesToSpawn = prepareEnemySpawnList(from: config)
        
        print("🎯 Will spawn \(levelTotal) enemies total: \(enemiesToSpawn)")
        
        spawnEnemiesWithDelay(enemies: enemiesToSpawn, delay: 2.0)
    }
    
    private func resetLevelData() {
        levelTotal = 0
        levelKilled = 0
        levelEscaped = 0
        spawnedCount = 0
        trackedEnemies.removeAll()
    }
    
    private func prepareEnemySpawnList(from config: LevelManager.LevelConfig) -> [EnemyType] {
        var enemiesToSpawn: [EnemyType] = []
        
        for (type, count) in config.enemies {
            for _ in 0..<count {
                enemiesToSpawn.append(type)
                levelTotal += 1
            }
        }
        
        enemiesToSpawn.shuffle()
        return enemiesToSpawn
    }
    
    private func spawnEnemiesWithDelay(enemies: [EnemyType], delay: TimeInterval) {
        guard let scene = scene else { return }
        
        for (index, enemyType) in enemies.enumerated() {
            let waitTime = delay * Double(index)
            let waitAction = SKAction.wait(forDuration: waitTime)
            let spawnAction = SKAction.run { [weak self] in
                self?.spawnSingleEnemy(type: enemyType)
            }
            
            scene.run(SKAction.sequence([waitAction, spawnAction]), withKey: "enemySpawn_\(index)")
        }
    }
    
    private func spawnSingleEnemy(type: EnemyType) {
        guard let scene = scene else { return }
        
        let spawnPosition = generateRandomSpawnPosition(sceneWidth: scene.frame.width,
                                                      sceneHeight: scene.frame.height)
        
        // Create enemy
        let enemy = Enemy(type: type, position: spawnPosition, scene: scene)
        allEnemies.append(enemy)
        scene.addChild(enemy.sprite)
        
        // Add to tracking
        let enemyId = ObjectIdentifier(enemy)
        trackedEnemies.insert(enemyId)
        spawnedCount += 1
        
        print("✅ Spawned \(type) at \(spawnPosition) - Count: \(spawnedCount)/\(levelTotal)")
        
        setupEnemyMovement(enemy: enemy, sceneHeight: scene.frame.height)
        setupBoundaryCheck(enemy: enemy)  // YENİ: Boundary kontrolü ekle
        enemy.startFiring(difficulty: 1)
    }
    
    private func generateRandomSpawnPosition(sceneWidth: CGFloat, sceneHeight: CGFloat) -> CGPoint {
        let minX = -sceneWidth/2 + 90
        let maxX = sceneWidth/2 - 90
        let randomX = CGFloat.random(in: minX...maxX)
        return CGPoint(x: randomX, y: sceneHeight/2 + 200)
    }
    
    // YENİ: Boundary kontrolü için sürekli kontrol
    private func setupBoundaryCheck(enemy: Enemy) {
        guard let scene = scene else { return }
        
        let checkAction = SKAction.run { [weak self, weak enemy] in
            guard let self = self,
                  let enemy = enemy,
                  enemy.sprite.parent != nil else { return }
            
            // Eğer düşman ekranın alt sınırını geçtiyse ve hala hayattaysa
            let bottomBoundary = -scene.frame.height/2 - 100
            
            if enemy.sprite.position.y < bottomBoundary && enemy.isAlive {
                print("🚨 Enemy \(enemy.type) escaped at y: \(enemy.sprite.position.y)")
                
                // Önce sprite'ı kaldır
                enemy.sprite.removeAllActions()
                enemy.sprite.removeFromParent()
                
                // Enemy'yi listeden kaldır
                self.removeEnemyFromLists(enemy: enemy)
                
                // Escaped olarak işaretle
                let id = ObjectIdentifier(enemy)
                if self.trackedEnemies.contains(id) {
                    self.markEscaped(enemy)
                }
            }
        }
        
        let wait = SKAction.wait(forDuration: 0.1)
        let sequence = SKAction.sequence([checkAction, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        enemy.sprite.run(repeatForever, withKey: "boundaryCheck")
    }
    
    private func setupEnemyMovement(enemy: Enemy, sceneHeight: CGFloat) {
        enemy.startMovement(sceneHeight: sceneHeight, difficulty: 1) { [weak self, weak enemy] in
            guard let self = self, let enemy = enemy else { return }
            
            print("🏃 Enemy \(enemy.type) reached movement completion - isAlive: \(enemy.isAlive)")
            
            // Movement tamamlandıysa ve enemy hala sprite'a sahipse
            if enemy.sprite.parent != nil {
                enemy.sprite.removeFromParent()
                self.removeEnemyFromLists(enemy: enemy)
                
                let id = ObjectIdentifier(enemy)
                if self.trackedEnemies.contains(id) {
                    // Eğer hala hayattaysa escaped olarak işaretle
                    if enemy.isAlive {
                        self.markEscaped(enemy)
                    }
                }
            }
        }
    }
    
    // MARK: - Enemy Management
    func removeEnemyFromLists(enemy: Enemy) {
        if let index = allEnemies.firstIndex(where: { $0 === enemy }) {
            allEnemies.remove(at: index)
            print("🗑️ Enemy removed from allEnemies list. Remaining: \(allEnemies.count)")
        }
    }
    
    func destroyEnemy(_ enemy: Enemy, damage: Int = 1) -> Int {
        // Eğer zaten ölmüşse işlem yapma
        guard enemy.isAlive else { return 0 }
        
        enemy.takeDamage(damage)
        
        if !enemy.isAlive {
            print("💥 Enemy destroyed: \(enemy.type)")
            let scoreValue = Enemy.getScoreValue(for: enemy.type)
            
            // Remove physics body to prevent additional collisions
            enemy.sprite.physicsBody = nil
            
            // Boundary check'i durdur
            enemy.sprite.removeAction(forKey: "boundaryCheck")
            
            // Enemy'yi killed olarak işaretle
            let id = ObjectIdentifier(enemy)
            if trackedEnemies.contains(id) {
                markKilled(enemy)
            }
            
            // Listeden kaldır
            removeEnemyFromLists(enemy: enemy)
            
            return scoreValue
        }
        
        return 0
    }
    
    func findEnemy(bySprite sprite: SKSpriteNode) -> Enemy? {
        return allEnemies.first { $0.sprite == sprite }
    }
    
    // MARK: - Level Progress Tracking
    
    // YENİ: Killed olarak işaretleme
    private func markKilled(_ enemy: Enemy) {
        let id = ObjectIdentifier(enemy)
        
        print("💀 Marking enemy as killed: \(enemy.type)")
        
        if trackedEnemies.remove(id) != nil {
            levelKilled += 1
            print("✅ Enemy killed. Progress: \(levelKilled) killed, \(levelEscaped) escaped, \(levelTotal) total")
            checkLevelCompletion()
        }
    }
    
    private func markEscaped(_ enemy: Enemy) {
        let id = ObjectIdentifier(enemy)
        
        print("🏃 Marking enemy as escaped: \(enemy.type)")
        
        if trackedEnemies.remove(id) != nil {
            levelEscaped += 1
            print("✅ Enemy escaped. Progress: \(levelKilled) killed, \(levelEscaped) escaped, \(levelTotal) total")
            checkLevelCompletion()
        }
    }
    
    // Eski fonksiyon kaldırıldı, artık kullanılmıyor
    func markRemovedIfTracked(_ enemy: Enemy) {
        // Bu fonksiyon artık GameScene'den çağrılmamalı
        // Killed durumu destroyEnemy içinde hallediliyor
    }
    
    private func checkLevelCompletion() {
        let processedTotal = levelKilled + levelEscaped
        
        print("📊 Level completion check: \(processedTotal)/\(levelTotal)")
        print("   - Killed: \(levelKilled)")
        print("   - Escaped: \(levelEscaped)")
        print("   - Remaining tracked: \(trackedEnemies.count)")
        
        guard processedTotal >= levelTotal && levelTotal > 0 else {
            print("⏳ Level still in progress")
            return
        }
        
        let stars = calculateStars()
        print("🎉 LEVEL COMPLETED! Stars: \(stars)")
        
        // Call completion handler only once
        if let completion = levelCompletion {
            levelCompletion = nil // Prevent duplicate calls
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(stars)
            }
        }
    }
    
    private func calculateStars() -> Int {
        guard levelTotal > 0 else { return 0 }
        
        let killRate = Double(levelKilled) / Double(levelTotal)
        
        if killRate >= 1.0 {
            return 3  // All enemies killed - 3 stars
        } else if killRate >= 0.75 {
            return 2  // 3/4+ enemies killed - 2 stars
        } else if killRate > 0 {
            return 1  // At least one enemy killed - 1 star
        } else {
            return 0  // No enemies killed - 0 stars
        }
    }
    
    // MARK: - Debug Methods
    private func printProgressStatus() {
        print("📊 Current progress - Killed: \(levelKilled), Escaped: \(levelEscaped), Total: \(levelTotal)")
        print("📋 Tracked enemies count: \(trackedEnemies.count)")
    }
    
    private func printTrackingDebug() {
        print("🐛 === TRACKING DEBUG ===")
        print("🎯 Level Total: \(levelTotal)")
        print("🏃 Tracked Count: \(trackedEnemies.count)")
        print("📊 Active Enemies: \(allEnemies.count)")
        print("🔄 Spawned Count: \(spawnedCount)")
        
        print("📋 Active enemies:")
        for (index, enemy) in allEnemies.enumerated() {
            let id = ObjectIdentifier(enemy)
            let isTracked = trackedEnemies.contains(id)
            print("   \(index). \(enemy.type) - alive: \(enemy.isAlive), tracked: \(isTracked), y: \(enemy.sprite.position.y)")
        }
        print("========================")
    }
    
    func printCurrentState() {
        print("🔍 ===== ENEMY MANAGER STATE =====")
        print("🎯 Level Total: \(levelTotal)")
        print("💀 Level Killed: \(levelKilled)")
        print("🏃 Level Escaped: \(levelEscaped)")
        print("📊 Active Enemies: \(allEnemies.count)")
        print("🏃 Tracked Enemies: \(trackedEnemies.count)")
        print("🔄 Spawned Count: \(spawnedCount)")
        print("⭐ Current Stars: \(currentStars)")
        print("================================")
        
        if !allEnemies.isEmpty {
            print("📋 Active enemy types:")
            for (index, enemy) in allEnemies.enumerated() {
                let id = ObjectIdentifier(enemy)
                let isTracked = trackedEnemies.contains(id)
                print("   \(index + 1). \(enemy.type) - alive: \(enemy.isAlive), tracked: \(isTracked), y: \(enemy.sprite.position.y)")
            }
        }
        print("================================")
    }
    
    // MARK: - Cleanup
    func cleanup() {
        print("🧹 Cleaning up EnemyManager...")
        
        // Stop all spawn actions
        scene?.removeAllActions()
        
        // Remove all enemies
        for enemy in allEnemies {
            enemy.sprite.removeAllActions()
            enemy.sprite.removeFromParent()
        }
        
        // Reset all data
        allEnemies.removeAll()
        resetLevelData()
        levelCompletion = nil
        
        print("✅ EnemyManager cleanup complete")
    }
    
    // MARK: - Public Getters
    var enemyCount: Int {
        return allEnemies.count
    }
    
    var enemies: [Enemy] {
        return allEnemies
    }
    
    var levelProgress: (killed: Int, escaped: Int, total: Int) {
        return (levelKilled, levelEscaped, levelTotal)
    }
    
    var isLevelComplete: Bool {
        return levelTotal > 0 && (levelKilled + levelEscaped) >= levelTotal
    }
    
    var currentStars: Int {
        return calculateStars()
    }
}
