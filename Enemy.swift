//
//  Enemy.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 12/08/2025.
//

import SpriteKit

enum EnemyType {
    case scout
    case bomber
    case heavyCrusier
    case kamikaze
    case sniper
    case elite
}

enum MovementPattern {
    case straight
    case zigzag
    case sine
    case dive
    case hover
    case circle
    case strafe
}

class Enemy {
    let sprite: SKSpriteNode
    let type: EnemyType
    private(set) var health: Int
    private(set) var maxHealth: Int
    private(set) var isAlive: Bool
    weak var scene: GameScene?
    
    private var movementPattern: MovementPattern = .straight
    private var isFiring: Bool = true
    var movementCancelled = false
    
    var scoreValue: Int {
        return Enemy.getScoreValue(for: type)
    }
    
    init(type: EnemyType, position: CGPoint, scene: GameScene) {
        self.type = type
        let textureName = Enemy.getTextureName(for: type)
        self.sprite = SKSpriteNode(imageNamed: textureName)
        
        let healthValue = Enemy.getHealth(for: type)
        self.health = healthValue
        self.maxHealth = healthValue
        
        self.isAlive = true
        self.scene = scene
        
        self.movementPattern = Enemy.getDefaultMovementPattern(for: type)
        
        setupSprite(at: position)
        setupHealthBar()
    }
    
    // MARK: - Static Helper Functions
    
    private static func getTextureName(for type: EnemyType) -> String {
        switch type {
        case .scout, .kamikaze: return "enemyScout"
        case .bomber, .sniper: return "enemyBomber"
        case .heavyCrusier, .elite: return "enemyHeavyCrusier"
        }
    }
    
    private static func getHealth(for type: EnemyType) -> Int {
        switch type {
        case .scout, .kamikaze: return 1
        case .sniper: return 2
        case .bomber: return 3
        case .heavyCrusier: return 5
        case .elite: return 8
        }
    }
    
    private static func getSize(for type: EnemyType) -> CGSize {
        switch type {
        case .scout, .kamikaze: return CGSize(width: 180, height: 280)
        case .bomber, .sniper: return CGSize(width: 200, height: 300)
        case .heavyCrusier, .elite: return CGSize(width: 280, height: 380)
        }
    }
    
    static func getScoreValue(for type: EnemyType) -> Int {
        switch type {
        case .scout: return 100
        case .kamikaze: return 150
        case .bomber: return 250
        case .sniper: return 300
        case .heavyCrusier: return 500
        case .elite: return 1000
        }
    }
    
    private static func getDefaultMovementPattern(for type: EnemyType) -> MovementPattern {
        switch type {
        case .scout: return .zigzag
        case .bomber: return .sine
        case .heavyCrusier: return .straight
        case .kamikaze: return .dive
        case .sniper: return .hover
        case .elite: return .strafe
        }
    }
    
    private static func getMoveDuration(for type: EnemyType, difficulty: Int) -> TimeInterval {
        let baseDuration: TimeInterval
        switch type {
        case .scout: baseDuration = 5.0
        case .bomber: baseDuration = 6.0
        case .heavyCrusier: baseDuration = 8.0
        case .kamikaze: baseDuration = 3.0
        case .sniper: baseDuration = 7.0
        case .elite: baseDuration = 10.0
        }
        return max(2.0, baseDuration - Double(difficulty) * 0.3)
    }
    
    private static func getFireInterval(for type: EnemyType, difficulty: Int) -> TimeInterval {
        let baseInterval: TimeInterval
        switch type {
        case .scout: baseInterval = 2.5
        case .bomber: baseInterval = 2.0
        case .heavyCrusier: baseInterval = 1.5
        case .kamikaze: baseInterval = 99.0 // Doesn't fire
        case .sniper: baseInterval = 3.0
        case .elite: baseInterval = 1.0
        }
        return max(0.5, baseInterval - Double(difficulty) * 0.1)
    }
    
    // MARK: - Setup Functions
    
    private func setupSprite(at position: CGPoint) {
        sprite.position = position
        sprite.zPosition = 5
        sprite.zRotation = .pi
        sprite.name = "enemy_\(type)"
        sprite.size = Enemy.getSize(for: type)
        
        // Type-specific color tints
        switch type {
        case .kamikaze:
            sprite.color = .orange
            sprite.colorBlendFactor = 0.5
        case .sniper:
            sprite.color = .cyan
            sprite.colorBlendFactor = 0.3
        case .elite:
            sprite.color = .purple
            sprite.colorBlendFactor = 0.4
        default:
            break
        }
        
        let realSize = CGSize(width: sprite.size.width * 0.88, height: sprite.size.height * 0.88)
        sprite.physicsBody = SKPhysicsBody(rectangleOf: realSize)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.playerBullet
        sprite.physicsBody?.allowsRotation = false
    }
    
    private func setupHealthBar() {
        guard maxHealth > 1 else { return }
        
        let barWidth: CGFloat = sprite.size.width * 0.8
        let barHeight: CGFloat = 8
        
        let bgBar = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: barHeight))
        bgBar.position = CGPoint(x: 0, y: sprite.size.height/2 + 20)
        bgBar.zPosition = 1
        bgBar.name = "healthBarBg"
        
        let healthBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
        healthBar.position = CGPoint(x: -barWidth/2, y: 0)
        healthBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        healthBar.zPosition = 2
        healthBar.name = "healthBar"
        
        bgBar.addChild(healthBar)
        sprite.addChild(bgBar)
    }
    
    private func updateHealthBar() {
        guard let healthBar = sprite.childNode(withName: "healthBarBg")?.childNode(withName: "healthBar") as? SKSpriteNode else { return }
        
        let healthPercent = CGFloat(health) / CGFloat(maxHealth)
        let barWidth = sprite.size.width * 0.8
        healthBar.size.width = barWidth * healthPercent
        
        if healthPercent > 0.6 {
            healthBar.color = .green
        } else if healthPercent > 0.3 {
            healthBar.color = .yellow
        } else {
            healthBar.color = .red
        }
    }
    
    // MARK: - Movement Functions
    
    func startMovement(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        startMovementWithPattern(movementPattern, sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
    }
    
    func startMovementWithPattern(_ pattern: MovementPattern, sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        self.movementPattern = pattern
        
        switch pattern {
        case .straight:
            moveStraight(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .zigzag:
            moveZigzag(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .sine:
            moveSine(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .dive:
            moveDive(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .hover:
            moveHover(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .circle:
            moveCircle(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        case .strafe:
            moveStrafe(sceneHeight: sceneHeight, difficulty: difficulty, onComplete: onComplete)
        }
    }
    
    private func moveStraight(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let moveDuration = Enemy.getMoveDuration(for: type, difficulty: difficulty)
        let moveDown = SKAction.moveBy(x: 0, y: -(sceneHeight + 400), duration: moveDuration)
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([moveDown, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveZigzag(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let moveDuration = Enemy.getMoveDuration(for: type, difficulty: difficulty)
        let moveDistance = sceneHeight + 400
        let segments = 5
        let segmentDistance = moveDistance / CGFloat(segments)
        
        var actions: [SKAction] = []
        for i in 0..<segments {
            let xOffset = (i % 2 == 0) ? 100 : -100
            let move = SKAction.moveBy(x: CGFloat(xOffset), y: -segmentDistance, duration: moveDuration/Double(segments))
            actions.append(move)
        }
        
        actions.append(SKAction.removeFromParent())
        
        sprite.run(SKAction.sequence(actions)) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveSine(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let moveDuration = Enemy.getMoveDuration(for: type, difficulty: difficulty)
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        
        let steps = 50
        let stepHeight = (sceneHeight + 400) / CGFloat(steps)
        
        for i in 1...steps {
            let y = -stepHeight * CGFloat(i)
            let x = sin(CGFloat(i) * 0.2) * 150
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        let followPath = SKAction.follow(path, asOffset: true, orientToPath: false, duration: moveDuration)
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([followPath, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveDive(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let pauseDuration = 1.0
        let diveDuration = 2.0
        
        let pause = SKAction.wait(forDuration: pauseDuration)
        let dive = SKAction.moveBy(x: 0, y: -(sceneHeight + 400), duration: diveDuration)
        let rotate = SKAction.rotate(byAngle: .pi * 4, duration: diveDuration)
        let diveGroup = SKAction.group([dive, rotate])
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([pause, diveGroup, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveHover(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let hoverDuration = 3.0
        let hover = SKAction.wait(forDuration: hoverDuration)
        let moveDuration = Enemy.getMoveDuration(for: type, difficulty: difficulty)
        let moveDown = SKAction.moveBy(x: 0, y: -(sceneHeight/2), duration: moveDuration/2)
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([hover, moveDown, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveCircle(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let radius: CGFloat = 150
        let circlePath = CGMutablePath()
        circlePath.addArc(center: CGPoint.zero, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        
        let circleAction = SKAction.follow(circlePath, asOffset: true, orientToPath: false, duration: 4.0)
        let repeatCircle = SKAction.repeat(circleAction, count: 3)
        let moveDown = SKAction.moveBy(x: 0, y: -(sceneHeight + 400), duration: 4.0)
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([repeatCircle, moveDown, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    private func moveStrafe(sceneHeight: CGFloat, difficulty: Int, onComplete: @escaping () -> Void) {
        let moveDuration = Enemy.getMoveDuration(for: type, difficulty: difficulty)
        let strafeRight = SKAction.moveBy(x: 120, y: -sceneHeight/3, duration: moveDuration/3)
        let strafeLeft = SKAction.moveBy(x: -120, y: -sceneHeight/3, duration: moveDuration/3)
        let strafeRight2 = SKAction.moveBy(x: 120, y: -sceneHeight/3, duration: moveDuration/3)
        let remove = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([strafeRight, strafeLeft, strafeRight2, remove])) {
            self.isAlive = false
            onComplete()
        }
    }
    
    // MARK: - Combat Functions
    
    func takeDamage(_ amount: Int = 1) {
        guard isAlive else { return }
        
        health -= amount
        updateHealthBar()
        
        if health <= 0 {
            die()
        } else {
            showHitEffect()
        }
    }

    private func die() {
        guard isAlive else { return }
        
        isAlive = false
        sprite.physicsBody = nil
        sprite.removeAllActions()
        movementCancelled = true
        
        // Explosion effect
        if let explosion = SKEmitterNode(fileNamed: "Explosion.sks") {
            explosion.position = sprite.position
            explosion.zPosition = 10
            scene?.addChild(explosion)
            
            let wait = SKAction.wait(forDuration: 1.0)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, remove]))
        }
        
        sprite.removeFromParent()
    }
    
    private func showHitEffect() {
        let originalColor = sprite.color
        let originalBlend = sprite.colorBlendFactor
        
        sprite.color = .gray
        sprite.colorBlendFactor = 0.8
        
        let wait = SKAction.wait(forDuration: 0.1)
        let revert = SKAction.run {
            self.sprite.color = originalColor
            self.sprite.colorBlendFactor = originalBlend
        }
        
        sprite.run(SKAction.sequence([wait, revert]))
    }
    
    func destroy() {
        sprite.removeAllActions()
        sprite.removeFromParent()
        isAlive = false
    }
    
    func startFiring(difficulty: Int) {
        guard isFiring, let scene = scene else { return }
        
        let fireInterval = Enemy.getFireInterval(for: type, difficulty: difficulty)
        let wait = SKAction.wait(forDuration: fireInterval)
        let fire = SKAction.run { [weak self] in
            self?.fireBullet()
        }
        let sequence = SKAction.sequence([fire, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        sprite.run(repeatForever, withKey: "enemyFiring")
    }
    
    private func fireBullet() {
        guard let scene = scene else { return }
        
        let bullet = SKSpriteNode(imageNamed: "enemyScoutBullet")
        bullet.size = CGSize(width: 140, height: 70)
        bullet.zRotation = -.pi/2
        bullet.position = CGPoint(x: sprite.position.x, y: sprite.position.y - sprite.size.height/2)
        bullet.zPosition = 4
        bullet.name = "enemyBullet"
        
        let realBulletSize = CGSize(width: bullet.size.width * 0.7, height: bullet.size.height * 0.7)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: realBulletSize)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.player
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        scene.addChild(bullet)
        
        let moveDown = SKAction.moveBy(x: 0, y: -scene.size.height, duration: 1.8)
        let remove = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveDown, remove]))
    }
}
