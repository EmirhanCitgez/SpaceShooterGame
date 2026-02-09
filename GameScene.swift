//
//  GameScene.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 09/08/2025.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Managers
    var playerManager: Player!
    var bulletManager: BulletManager!
    var effectsManager: EffectsManager!
    var uiManager: UIManager!
    var enemyManager: EnemyManager!
    let levelManager = LevelManager()
    
    // MARK: - Game State Properties
    var selectedLevelIndex: Int = 1
    private var currentScore: Int = 0
    var gameStarted = false
    var isLevelComplete = false
    var isGamePaused = false
    
    // MARK: - Scene Setup
    override func didMove(to view: SKView) {
        setupScene()
        setupManagers()
        startLevel(index: selectedLevelIndex)
        
        print("Level \(selectedLevelIndex) loaded successfully.")
    }
    
    private func setupScene() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsBody?.categoryBitMask = PhysicsCategory.boundary
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.scene?.scaleMode = .aspectFit
        self.physicsWorld.contactDelegate = self
        
        // Camera setup
        let camera = SKCameraNode()
        self.camera = camera
        addChild(camera)
    }
    
    private func setupManagers() {
        // Player setup from existing scene node
        let playerNode = childNode(withName: "player") as! SKSpriteNode
        playerManager = Player(texture: "player1", position: playerNode.position, scene: self)
        playerNode.removeFromParent()
        addChild(playerManager.sprite)
        
        // Initialize other managers
        bulletManager = BulletManager(scene: self)
        effectsManager = EffectsManager(scene: self)
        uiManager = UIManager(scene: self)
        uiManager.setupUI()
        uiManager.startTimer()
        enemyManager = EnemyManager(scene: self, bulletManager: bulletManager)
        
        // Reset game states
        isLevelComplete = false
        isGamePaused = false
    }
    
    // MARK: - Level Management
    func startLevel(index: Int) {
        guard let config = levelManager.startLevel(index) else { return }
        
        // Reset level states
        isLevelComplete = false
        isGamePaused = false
        
        enemyManager.spawnEnemies(for: config) { [weak self] stars in
            guard let self = self else { return }
            
            // Only complete level if game is still active
            guard !self.isLevelComplete && !self.isGamePaused else { return }
            
            print("Level \(index) completed - \(stars) stars earned")
            self.onLevelComplete(levelIndex: index, stars: stars)
        }
    }
    
    private func onLevelComplete(levelIndex: Int, stars: Int) {
        // Prevent duplicate level completion
        guard !isLevelComplete else { return }
        
        isLevelComplete = true
        isGamePaused = true
        
        // Stop player actions
        playerManager.stopFiring()
        playerManager.sprite.removeAllActions()
        
        // Pause all game elements
        pauseAllGameElements()
        
        let finalScore = uiManager.score
        let timeString = uiManager.formattedTime
        
        // Show level complete UI with star count
        uiManager.setupLevelCompleteUI(
            levelIndex: levelIndex,
            score: finalScore,
            timeString: timeString,
            stars: stars,
            onRestart: { [weak self] in
                self?.restartCurrentLevel()
            },
            onMap: { [weak self] in
                self?.goToMap()
            },
            onNext: { [weak self] in
                self?.goToNextLevel()
            }
        )
    }
    
    // MARK: - Game State Control
    private func pauseAllGameElements() {
        // Pause all enemies
        for enemy in enemyManager.enemies {
            enemy.sprite.isPaused = true
        }
        
        // Pause all bullets
        enumerateChildNodes(withName: "bullet") { node, _ in
            node.isPaused = true
        }
        
        enumerateChildNodes(withName: "enemyBullet") { node, _ in
            node.isPaused = true
        }
    }
    
    private func resumeAllGameElements() {
        // Resume all enemies
        for enemy in enemyManager.enemies {
            enemy.sprite.isPaused = false
        }
        
        // Resume all bullets
        enumerateChildNodes(withName: "bullet") { node, _ in
            node.isPaused = false
        }
        
        enumerateChildNodes(withName: "enemyBullet") { node, _ in
            node.isPaused = false
        }
    }
    
    // MARK: - Level Navigation
    private func restartCurrentLevel() {
        print("🔄 Restarting current level \(selectedLevelIndex)")
        uiManager.hideLevelCompletePopup()
        cleanup()
        SceneManager.shared.goToGame(levelIndex: selectedLevelIndex, forceRestart: true)
    }

    private func goToMap() {
        print("🗺️ Going to map")
        uiManager.hideLevelCompletePopup()
        cleanup()
        SceneManager.shared.goToMap()
    }

    private func goToNextLevel() {
        let nextLevelIndex = selectedLevelIndex + 1
        print("➡️ Going to next level \(nextLevelIndex)")
        
        uiManager.hideLevelCompletePopup()
        cleanup()
        
        selectedLevelIndex = nextLevelIndex
        currentScore = 0
        uiManager.updateScore(newScore: currentScore)
        
        // Reset states
        isLevelComplete = false
        isGamePaused = false
        resumeAllGameElements()
        
        uiManager.startTimer()
        startLevel(index: selectedLevelIndex)
    }
    
    // MARK: - Score Management
    func addScore(points: Int) {
        currentScore += points
        uiManager.updateScore(newScore: currentScore)
    }
    
    // MARK: - Player Death
    func playerDidDie(at position: CGPoint, size: CGSize) {
        print("🔴 Player died")
        
        isGamePaused = true
        
        // Stop all actions
        removeAllActions()
        bulletManager.removeAllBullets()
        
        // Show explosion effect
        effectsManager.showExplosion(at: position, size: size)
        effectsManager.shakeScreen()
        
        // Remove player
        playerManager.sprite.removeAllActions()
        playerManager.sprite.removeFromParent()
        
        // Show game over screen
        uiManager.showGameOver()
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        print("TOUCH BAŞLADI - Player alive: \(playerManager.isAlive)")
        print("TOUCH BAŞLADI - Level complete: \(isLevelComplete)")
        print("TOUCH BAŞLADI - Game paused: \(isGamePaused)")
        
        // Priority 1: Level complete popup
        if uiManager.handleLevelCompleteTouch(at: touchLocation) {
            return
        }
        
        // Priority 2: Player death state (BUNU ÖNE ALDIK!)
        if !playerManager.isAlive {
            let touchedNode = atPoint(touchLocation)
            print("Touched node: \(touchedNode.name ?? "nil")")
            
            if touchedNode.name == "restart" {
                print("Restart button touched!")
                SceneManager.shared.restartGame()
                return
            }
            return
        }
        
        // Priority 3: Game state checks
        guard !isLevelComplete && !isGamePaused else {
            return
        }
        
        // Priority 4: Normal gameplay
        playerManager.moveToPosition(touchLocation)
        playerManager.startFiring()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard playerManager.isAlive && !isLevelComplete && !isGamePaused else { return }
        
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            playerManager.moveToPosition(touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard playerManager.isAlive && !isLevelComplete && !isGamePaused else { return }
        playerManager.stopFiring()
    }
    
    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        // Game state checks
        guard !isLevelComplete && !isGamePaused else { return }
        guard playerManager.isAlive else { return }
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        let aCat = bodyA.categoryBitMask
        let bCat = bodyB.categoryBitMask

        // Player bullet hits enemy
        if (aCat == PhysicsCategory.playerBullet && bCat == PhysicsCategory.enemy) ||
           (aCat == PhysicsCategory.enemy && bCat == PhysicsCategory.playerBullet) {
            
            handlePlayerBulletEnemyCollision(bodyA: bodyA, bodyB: bodyB, aCat: aCat)
            return
        }

        // Player hit by enemy bullet
        if (aCat == PhysicsCategory.player && bCat == PhysicsCategory.enemyBullet) ||
           (aCat == PhysicsCategory.enemyBullet && bCat == PhysicsCategory.player) {
            
            handlePlayerEnemyBulletCollision(bodyA: bodyA, bodyB: bodyB, aCat: aCat)
            return
        }
        
        // Player hit by kamikaze enemy
        if (aCat == PhysicsCategory.player && bCat == PhysicsCategory.enemy) ||
           (aCat == PhysicsCategory.enemy && bCat == PhysicsCategory.player) {
            
            handlePlayerKamikazeCollision(bodyA: bodyA, bodyB: bodyB, aCat: aCat)
            return
        }
    }
    
    private func handlePlayerBulletEnemyCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, aCat: UInt32) {
        let bullet = aCat == PhysicsCategory.playerBullet ? bodyA.node : bodyB.node
        let enemy = aCat == PhysicsCategory.enemy ? bodyA.node : bodyB.node
        
        guard let bulletNode = bullet as? SKSpriteNode,
              let enemyNode = enemy as? SKSpriteNode,
              let enemyObject = enemyManager.findEnemy(bySprite: enemyNode),
              enemyObject.isAlive else { return }
        
        bulletNode.removeFromParent()
        
        // Destroy enemy and get score - destroyEnemy artık killed durumunu hallediyor
        let score = enemyManager.destroyEnemy(enemyObject)
        
        // markRemovedIfTracked çağrısını KALDIRDIK - artık destroyEnemy içinde hallediliyor
        
        if score > 0 {
            effectsManager.showExplosion(at: enemyNode.position, size: enemyNode.size)
            effectsManager.shakeScreen()
            uiManager.addScore(points: score)
        }
    }
    
    private func handlePlayerEnemyBulletCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, aCat: UInt32) {
        let bulletNode = aCat == PhysicsCategory.enemyBullet ? bodyA.node : bodyB.node
        bulletNode?.removeFromParent()
        
        effectsManager.flashScreen()
        playerManager.takeDamage()
    }
    
    private func handlePlayerKamikazeCollision(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody, aCat: UInt32) {
        guard let enemyNode = (aCat == PhysicsCategory.enemy ? bodyA.node : bodyB.node) as? SKSpriteNode,
              let enemyObject = enemyManager.findEnemy(bySprite: enemyNode),
              enemyObject.type == .kamikaze,
              enemyObject.isAlive else { return }
        
        // Kamikaze düşmanı tamamen yok et ve skor al
        let score = enemyManager.destroyEnemy(enemyObject, damage: enemyObject.health)
        
        // markRemovedIfTracked çağrısını KALDIRDIK - artık destroyEnemy içinde hallediliyor
        
        if score > 0 {
            effectsManager.showExplosion(at: enemyNode.position, size: enemyNode.size)
            playerManager.takeDamage()
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        removeAllActions()
        enemyManager.cleanup()
        bulletManager.removeAllBullets()
        
        // Reset states
        isLevelComplete = false
        isGamePaused = false
    }
    
    func restartGame() {
        // Clean scene
        removeAllChildren()
        removeAllActions()
        
        // Reset variables
        enemyManager.cleanup()
        
        // Restart scene
        SceneManager.shared.restartGame()
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        // Only update timer if game is active
        if !isGamePaused {
            uiManager.updateTimer()
        }
    }
    
    // MARK: - Unused Touch Methods (kept for protocol compliance)
    func touchDown(atPoint pos : CGPoint) {}
    func touchMoved(toPoint pos : CGPoint) {}
    func touchUp(atPoint pos : CGPoint) {}
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
}
