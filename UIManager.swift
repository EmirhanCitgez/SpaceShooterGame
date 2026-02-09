//
//  UIManager.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 13/08/2025.
//

import SpriteKit

class UIManager {
    weak var scene: SKScene?
    
    // UI elements - Sol üst
    private var healthContainer: SKShapeNode!
    private var healthLabel: SKLabelNode!
    private var healthIcon: SKSpriteNode!
    
    private var armorContainer: SKShapeNode!
    private var armorLabel: SKLabelNode!
    private var armorIcon: SKSpriteNode!
    
    // UI elements - Sağ üst
    private var scoreContainer: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var scoreTitleLabel: SKLabelNode!
    
    private var timerContainer: SKShapeNode!
    private var timerLabel: SKLabelNode!
    private var timerIcon: SKSpriteNode!
    
    // Game Over elements
    private var gameOverLabel: SKLabelNode?
    private var restartLabel: SKLabelNode?
    
    // Game Data
    private var currentScore: Int = 0
    private var currentHealth: Int = 10
    private var currentArmor: Int = 5
    private var gameStartTime: TimeInterval = 0
    private var currentGameTime: TimeInterval = 0
    private var isTimerRunning: Bool = false
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    // Tüm UI elementlerini kurar
    func setupUI() {
        setupHealthDisplay()
        setupArmorDisplay()
        setupScoreDisplay()
        setupTimerDisplay()
    }
    
    // MARK: - Sol Üst UI (Health & Armor)
    
    private func setupHealthDisplay() {
        guard let scene = scene else { return }
        
        // Container box
        healthContainer = SKShapeNode(rectOf: CGSize(width: 220, height: 75), cornerRadius: 12)
        healthContainer.fillColor = SKColor.black.withAlphaComponent(0.6)
        healthContainer.strokeColor = SKColor.red
        healthContainer.lineWidth = 2
        healthContainer.position = CGPoint(x: scene.frame.minX + 150, y: scene.frame.maxY - 100)
        healthContainer.zPosition = 10
        scene.addChild(healthContainer)
        
        // Health icon (kalp simgesi gibi bir şey kullanabilirsiniz)
        healthIcon = SKSpriteNode(imageNamed: "Hearth") // Eğer health icon asset'iniz varsa
        healthIcon.size = CGSize(width: 55, height: 55)
        healthIcon.position = CGPoint(x: -70, y: 0)
        healthIcon.zPosition = 1
        healthContainer.addChild(healthIcon)
        
        // Eğer icon yoksa, emoji kullanabilirsiniz
        if healthIcon.texture == nil {
            healthIcon.removeFromParent()
            let heartLabel = SKLabelNode(text: "❤️")
            heartLabel.fontSize = 30
            heartLabel.position = CGPoint(x: -70, y: -12)
            heartLabel.zPosition = 1
            healthContainer.addChild(heartLabel)
        }
        
        // Health value label
        healthLabel = SKLabelNode(fontNamed: "Arial-Bold")
        healthLabel.text = "\(currentHealth) / 10"
        healthLabel.fontSize = 34
        healthLabel.fontColor = .white
        healthLabel.horizontalAlignmentMode = .center
        healthLabel.position = CGPoint(x: 18, y: -12)
        healthLabel.zPosition = 1
        healthContainer.addChild(healthLabel)
    }
    
    private func setupArmorDisplay() {
        guard let scene = scene else { return }
        
        // Container box
        armorContainer = SKShapeNode(rectOf: CGSize(width: 220, height: 75), cornerRadius: 12)
        armorContainer.fillColor = SKColor.black.withAlphaComponent(0.7)
        armorContainer.strokeColor = SKColor.cyan
        armorContainer.lineWidth = 2
        armorContainer.position = CGPoint(x: scene.frame.minX + 150, y: scene.frame.maxY - 190)
        armorContainer.zPosition = 10
        scene.addChild(armorContainer)
        
        // Armor icon
        armorIcon = SKSpriteNode(imageNamed: "Shield") // Eğer armor icon asset'iniz varsa
        armorIcon.size = CGSize(width: 45, height: 45)
        armorIcon.position = CGPoint(x: -70, y: 0)
        armorIcon.zPosition = 1
        armorContainer.addChild(armorIcon)
        
        // Eğer icon yoksa, emoji kullanabilirsiniz
        if armorIcon.texture == nil {
            armorIcon.removeFromParent()
            let shieldLabel = SKLabelNode(text: "🛡️")
            shieldLabel.fontSize = 30
            shieldLabel.position = CGPoint(x: -70, y: -12)
            shieldLabel.zPosition = 1
            armorContainer.addChild(shieldLabel)
        }
        
        // Armor value label
        armorLabel = SKLabelNode(fontNamed: "Arial-Bold")
        armorLabel.text = "\(currentArmor) / 5"
        armorLabel.fontSize = 34
        armorLabel.fontColor = .white
        armorLabel.horizontalAlignmentMode = .center
        armorLabel.position = CGPoint(x: 18, y: -12)
        armorLabel.zPosition = 1
        armorContainer.addChild(armorLabel)
    }
    
    // MARK: - Sağ Üst UI (Score & Timer)
    
    private func setupScoreDisplay() {
        guard let scene = scene else { return }
        
        // Container box
        scoreContainer = SKShapeNode(rectOf: CGSize(width: 250, height: 70), cornerRadius: 10)
        scoreContainer.fillColor = SKColor.black.withAlphaComponent(0.7)
        scoreContainer.strokeColor = SKColor.yellow
        scoreContainer.lineWidth = 2
        scoreContainer.position = CGPoint(x: scene.frame.maxX - 160, y: scene.frame.maxY - 105)
        scoreContainer.zPosition = 10
        scene.addChild(scoreContainer)
        
        // Score title
        scoreTitleLabel = SKLabelNode(fontNamed: "Arial")
        scoreTitleLabel.text = "SCORE"
        scoreTitleLabel.fontSize = 18
        scoreTitleLabel.fontColor = SKColor.yellow
        scoreTitleLabel.position = CGPoint(x: 0, y: 15)
        scoreTitleLabel.zPosition = 1
        scoreContainer.addChild(scoreTitleLabel)
        
        // Score value
        scoreLabel = SKLabelNode(fontNamed: "Arial-Bold")
        scoreLabel.text = "\(currentScore)"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: 0, y: -20)
        scoreLabel.zPosition = 1
        scoreContainer.addChild(scoreLabel)
    }
    
    private func setupTimerDisplay() {
        guard let scene = scene else { return }
        
        // Container box
        timerContainer = SKShapeNode(rectOf: CGSize(width: 250, height: 60), cornerRadius: 10)
        timerContainer.fillColor = SKColor.black.withAlphaComponent(0.7)
        timerContainer.strokeColor = SKColor.green
        timerContainer.lineWidth = 2
        timerContainer.position = CGPoint(x: scene.frame.maxX - 160, y: scene.frame.maxY - 185)
        timerContainer.zPosition = 10
        scene.addChild(timerContainer)
        
        // Timer icon
        timerIcon = SKSpriteNode(imageNamed: "Clock_Icon")
        timerIcon.size = CGSize(width: 35, height: 35)
        timerIcon.position = CGPoint(x: -85, y: 0)
        timerIcon.zPosition = 1
        timerContainer.addChild(timerIcon)
        
        // Eğer icon yoksa emoji kullan
        if timerIcon.texture == nil {
            timerIcon.removeFromParent()
            let clockLabel = SKLabelNode(text: "⏱️")
            clockLabel.fontSize = 30
            clockLabel.position = CGPoint(x: -85, y: -12)
            clockLabel.zPosition = 1
            timerContainer.addChild(clockLabel)
        }
        
        // Timer label
        timerLabel = SKLabelNode(fontNamed: "Arial-Bold")
        timerLabel.text = "00:00"
        timerLabel.fontSize = 32
        timerLabel.fontColor = .white
        timerLabel.position = CGPoint(x: 20, y: -12)
        timerLabel.zPosition = 1
        timerContainer.addChild(timerLabel)
    }
    
    // MARK: - Update Functions
    
    func updateLivesDots(_ lives: Int) {
        currentHealth = lives
        healthLabel?.text = "\(currentHealth) / 10"
        
        // Can az ise container'ı yanıp söndür
        if lives <= 2 {
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            let blink = SKAction.sequence([fadeOut, fadeIn])
            healthContainer?.run(SKAction.repeatForever(blink), withKey: "healthBlink")
            healthContainer?.strokeColor = SKColor.red
            healthContainer?.lineWidth = 3
        } else {
            healthContainer?.removeAction(forKey: "healthBlink")
            healthContainer?.alpha = 1.0
            healthContainer?.strokeColor = SKColor.red
            healthContainer?.lineWidth = 2
        }
    }
    
    func updateArmorDot(_ armor: Int) {
        currentArmor = armor
        armorLabel?.text = "\(currentArmor) / 5"
        
        // Armor az ise container'ı yanıp söndür
        if armor <= 1 && armor > 0 {
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.5)
            let blink = SKAction.sequence([fadeOut, fadeIn])
            armorContainer?.run(SKAction.repeatForever(blink), withKey: "armorBlink")
            armorContainer?.strokeColor = SKColor.orange
            armorContainer?.lineWidth = 3
        } else if armor == 0 {
            armorContainer?.alpha = 0.5
            armorContainer?.removeAction(forKey: "armorBlink")
        } else {
            armorContainer?.removeAction(forKey: "armorBlink")
            armorContainer?.alpha = 1.0
            armorContainer?.strokeColor = SKColor.cyan
            armorContainer?.lineWidth = 2
        }
    }
    
    func updateScore(newScore: Int) {
        currentScore = newScore
        scoreLabel?.text = "\(currentScore)"
        
        // Skor arttığında küçük scale efekti
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1, duration: 0.1)
        scoreLabel?.run(SKAction.sequence([scaleUp, scaleDown]))
        
        // Container'a da kısa bir highlight efekti
        let originalColor = scoreContainer?.strokeColor ?? SKColor.yellow
        scoreContainer?.strokeColor = SKColor.white
        let wait = SKAction.wait(forDuration: 0.2)
        let resetColor = SKAction.run { [weak self] in
            self?.scoreContainer?.strokeColor = originalColor
        }
        scoreContainer?.run(SKAction.sequence([wait, resetColor]))
    }
    
    func addScore(points: Int) {
        updateScore(newScore: currentScore + points)
    }
    
    // MARK: - Timer Functions
    
    func startTimer() {
        gameStartTime = CACurrentMediaTime()
        currentGameTime = 0
        isTimerRunning = true
        timerLabel?.text = "00:00"
        print("Timer Started")
    }
    
    func stopTimer() {
        isTimerRunning = false
        print("Timer Stopped at: \(currentGameTime)")
    }
    
    func updateTimer() {
        guard isTimerRunning else { return }
        
        currentGameTime = CACurrentMediaTime() - gameStartTime
        timerLabel?.text = formatTime(currentGameTime)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let totalSecond = Int(time)
        let minutes = totalSecond / 60
        let seconds = totalSecond % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // **MARK: - Game Over Screen**
    func showGameOver() {
        guard let scene = scene else { return }
        
        stopTimer()
        
        // Ana overlay - animasyonlu arka plan
        let overlay = SKSpriteNode(color: .clear, size: CGSize(width: scene.frame.width, height: scene.frame.height))
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = 14
        overlay.name = "gameOverOverlay"
        scene.addChild(overlay)
        
        // Animasyonlu arka plan partikülleri
        createSpaceParticles(parent: overlay)
        
        // Yarı şeffaf karanlık katman
        let darkOverlay = SKSpriteNode(color: .black, size: CGSize(width: scene.frame.width, height: scene.frame.height))
        darkOverlay.position = CGPoint(x: 0, y: 0)
        darkOverlay.alpha = 0.8
        darkOverlay.zPosition = 1
        overlay.addChild(darkOverlay)
        
        // Ana container - hologram benzeri
        let mainContainer = createHologramContainer()
        mainContainer.zPosition = 2
        overlay.addChild(mainContainer)
        
        // Başlat animasyonları
        animateModernGameOver()
    }

    private func createSpaceParticles(parent: SKNode) {
        // Yıldız partikülleri
        for i in 0..<30 {
            let star = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 2))
            star.position = CGPoint(
                x: CGFloat.random(in: -scene!.frame.width/2...scene!.frame.width/2),
                y: CGFloat.random(in: -scene!.frame.height/2...scene!.frame.height/2)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            star.zPosition = 0
            
            // Twinkle animasyonu
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: CGFloat.random(in: 1.0...3.0))
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: CGFloat.random(in: 1.0...3.0))
            let twinkle = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(twinkle))
            
            parent.addChild(star)
        }
        
        // Kızıl partiküller (patlama artıkları)
        for i in 0..<15 {
            let debris = SKSpriteNode(color: .systemRed.withAlphaComponent(0.6),
                                     size: CGSize(width: 3, height: 3))
            debris.position = CGPoint(x: 0, y: 0) // Merkezi başlangıç
            debris.zPosition = 0
            
            // Rastgele yönlerde saçılma
            let randomX = CGFloat.random(in: -200...200)
            let randomY = CGFloat.random(in: -200...200)
            let spread = SKAction.moveBy(x: randomX, y: randomY, duration: 2.0)
            let fadeOut = SKAction.fadeOut(withDuration: 2.0)
            let group = SKAction.group([spread, fadeOut])
            let remove = SKAction.removeFromParent()
            debris.run(SKAction.sequence([group, remove]))
            
            parent.addChild(debris)
        }
    }

    private func createHologramContainer() -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: 0)
        
        
        // Arka plan - koyu mavi hologram
        let background = SKSpriteNode(imageNamed: "Window")
        background.size = CGSize(width: 925, height: 1100)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = 0
        container.addChild(background)
        
        // Game Over ana başlık
        gameOverLabel = SKLabelNode(text: "MISSION FAILED")
        gameOverLabel?.fontName = "Ethnocentric-Regular"
        gameOverLabel?.fontSize = 58
        gameOverLabel?.fontColor = .systemRed
        gameOverLabel?.position = CGPoint(x: 0, y: 450)
        gameOverLabel?.zPosition = 1
        container.addChild(gameOverLabel!)
        
        // Skor paneli
        let scorePanel = createScorePanel()
        scorePanel.position = CGPoint(x: 0, y: 200)
        scorePanel.zPosition = 1
        container.addChild(scorePanel)
        
        // Timer paneli
        let timerPanel = createTimerPanel()
        timerPanel.position = CGPoint(x: 0, y: 25)
        timerPanel.zPosition = 1
        container.addChild(timerPanel)
        
        // Restart butonu - sci-fi tarzı
        let restartButton = createSciFiRestartButton()
        restartButton.position = CGPoint(x: 0, y: -415)
        restartButton.zPosition = 1
        container.addChild(restartButton)
        
        return container
    }

    private func createScorePanel() -> SKNode {
        let container = SKNode()
        
        // Skor arka planı
        let background = SKSpriteNode(color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8),
                                     size: CGSize(width: 400, height: 125))
        background.position = CGPoint(x: 0, y: 0)
        container.addChild(background)
        
        // Skor kenar çerçevesi
        let border = SKSpriteNode(color: .systemYellow, size: CGSize(width: 404, height: 129))
        border.position = CGPoint(x: 0, y: 0)
        border.zPosition = -1
        container.addChild(border)
        
        // "FINAL SCORE" etiketi
        let titleLabel = SKLabelNode(text: "FINAL SCORE")
        titleLabel.fontName = "Ethnocentric-Regular"
        titleLabel.fontSize = 26
        titleLabel.fontColor = .systemYellow
        titleLabel.position = CGPoint(x: 0, y: 22)
        container.addChild(titleLabel)
        
        // Skor değeri
        let scoreValue = SKLabelNode(text: "\(currentScore)")
        scoreValue.fontName = "Ethnocentric-Regular"
        scoreValue.fontSize = 34
        scoreValue.fontColor = .white
        scoreValue.position = CGPoint(x: 0, y: -25)
        container.addChild(scoreValue)
        
        return container
    }
    
    private func createTimerPanel() -> SKNode {
        let container = SKNode()
        
        // Skor arka planı
        let background = SKSpriteNode(color: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8),
                                     size: CGSize(width: 400, height: 125))
        background.position = CGPoint(x: 0, y: 0)
        container.addChild(background)
        
        // Timer kenar çerçevesi
        let border = SKSpriteNode(color: .systemYellow, size: CGSize(width: 404, height: 129))
        border.position = CGPoint(x: 0, y: 0)
        border.zPosition = -1
        container.addChild(border)
        
        // "Time" etiketi
        let titleLabel = SKLabelNode(text: "Time")
        titleLabel.fontName = "Ethnocentric-Regular"
        titleLabel.fontSize = 26
        titleLabel.fontColor = .systemYellow
        titleLabel.position = CGPoint(x: 0, y: 22)
        container.addChild(titleLabel)
        
        // timer değeri
        let timerValue = SKLabelNode(text: "\(Int(currentGameTime))")
        timerValue.fontName = "Ethnocentric-Regular"
        timerValue.fontSize = 34
        timerValue.fontColor = .white
        timerValue.position = CGPoint(x: 0, y: -25)
        container.addChild(timerValue)
        
        return container
    }

    private func createSciFiRestartButton() -> SKNode {
        let container = SKNode()
        container.name = "restart"
        
        // Ana buton arka planı
        let buttonBg = SKSpriteNode(imageNamed: "Replay_BTN")
        buttonBg.size = CGSize(width: 180, height: 180)
        buttonBg.position = CGPoint(x: 0, y: 0)
        buttonBg.name = "restart"
        container.addChild(buttonBg)
        
        return container
    }

    private func animateModernGameOver() {
        guard let scene = scene else { return }
        
        // Ana container için slide-down animasyonu
        if let overlay = scene.childNode(withName: "gameOverOverlay"),
           let container = overlay.children.last(where: { !($0 is SKSpriteNode && ($0 as! SKSpriteNode).color == .black) }) {
            
            container.position = CGPoint(x: 0, y: scene.frame.height)
            container.alpha = 0
            
            let slideDown = SKAction.moveTo(y: 0, duration: 0.8)
            slideDown.timingMode = .easeOut
            let fadeIn = SKAction.fadeIn(withDuration: 0.8)
            let group = SKAction.group([slideDown, fadeIn])
            
            container.run(group)
        }
        
        // Game Over text için glitch efekti
        gameOverLabel?.alpha = 0
        gameOverLabel?.setScale(0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.glitchEffect()
        }
        
        // Restart button için pulse animasyonu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.pulseRestartButton()
        }
    }

    private func glitchEffect() {
        guard let label = gameOverLabel else { return }
        
        // İlk glitch
        let scaleUp1 = SKAction.scale(to: 1.2, duration: 0.05)
        let scaleDown1 = SKAction.scale(to: 0.8, duration: 0.05)
        let scaleNormal1 = SKAction.scale(to: 1.0, duration: 0.05)
        let fadeIn1 = SKAction.fadeIn(withDuration: 0.05)
        
        let glitch1 = SKAction.group([
            SKAction.sequence([scaleUp1, scaleDown1, scaleNormal1]),
            fadeIn1
        ])
        
        // İkinci glitch
        let moveRight = SKAction.moveBy(x: 5, y: 0, duration: 0.03)
        let moveLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.03)
        let moveBack = SKAction.moveBy(x: 5, y: 0, duration: 0.03)
        let shake = SKAction.sequence([moveRight, moveLeft, moveBack])
        
        let wait = SKAction.wait(forDuration: 0.2)
        let finalGlitch = SKAction.sequence([glitch1, wait, shake])
        
        label.run(finalGlitch)
    }

    private func pulseRestartButton() {
        guard let scene = scene,
              let restartButton = scene.childNode(withName: "//restart") else { return }
        
        let scaleUp = SKAction.scale(to: 1.08, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        // Renk değişimi
        let highlightAction = SKAction.run {
            for child in restartButton.children {
                if let sprite = child as? SKSpriteNode {
                    if sprite.color == UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9) {
                        let colorize = SKAction.colorize(with: .systemOrange, colorBlendFactor: 0.3, duration: 1.0)
                        let decolorize = SKAction.colorize(with: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.9), colorBlendFactor: 1.0, duration: 1.0)
                        sprite.run(SKAction.sequence([colorize, decolorize]))
                    }
                }
            }
        }
        
        let combined = SKAction.group([pulse, highlightAction])
        restartButton.run(SKAction.repeatForever(combined))
    }
    
    // MARK: - Temporary Messages
    
    func showTemporaryMessage(_ text: String, duration: TimeInterval = 2.0) {
        guard let scene = scene else { return }
        
        let messageLabel = SKLabelNode(text: text)
        messageLabel.fontName = "Arial-Bold"
        messageLabel.fontSize = 40
        messageLabel.position = CGPoint(x: 0, y: 100)
        messageLabel.zPosition = 12
        
        scene.addChild(messageLabel)
        
        // Animasyon
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: duration - 0.6)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        messageLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    // MARK: - Level Complete UI
    
    func setupLevelCompleteUI(levelIndex: Int, score: Int, timeString: String, stars: Int, onRestart: @escaping () -> Void, onMap: @escaping () -> Void, onNext: @escaping () -> Void) {
        guard let scene = scene else { return }
        
        stopTimer()
        
        // Yarı şeffaf overlay
        let overlay = SKSpriteNode(color: .black, size: CGSize(width: scene.frame.width, height: scene.frame.height))
        overlay.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        overlay.position = CGPoint(x: scene.frame.midX, y: scene.frame.midY)
        overlay.zPosition = 20
        overlay.alpha = 0.6
        overlay.name = "LevelCompleteOverlay"
        scene.addChild(overlay)
        
        // Ana popUp penceresi
        let popUp = SKSpriteNode(imageNamed: "Window")
        popUp.size = CGSize(width: scene.frame.width/1.2, height: scene.frame.height/2.2)
        popUp.position = CGPoint(x: 0, y: 0)
        popUp.zPosition = 21
        popUp.name = "LevelCompletePopup"
        scene.addChild(popUp)
        
        // Level Complete başlığı
        let titleLabel = SKLabelNode(text: "Level \(levelIndex)")
        titleLabel.fontName = "Ethnocentric-Regular"
        titleLabel.fontSize = 75
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 470)
        titleLabel.zPosition = 22
        popUp.addChild(titleLabel)
        
        let completeLabel = SKLabelNode(text: "COMPLETED!")
        completeLabel.fontName = "Ethnocentric-Regular"
        completeLabel.fontSize = 58
        completeLabel.fontColor = .yellow
        completeLabel.position = CGPoint(x: 0, y: 340)
        completeLabel.zPosition = 22
        popUp.addChild(completeLabel)
        
        // Yıldızları göster
        setupStarsDisplay(on: popUp, stars: stars)
        
        // Skor göstergesi
        let scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontName = "Ethnocentric-Regular"
        scoreLabel.fontColor = .green
        scoreLabel.fontSize = 48
        scoreLabel.position = CGPoint(x: 0, y: -130)
        scoreLabel.zPosition = 22
        popUp.addChild(scoreLabel)
        
        // Süre göstergesi
        let timeLabel = SKLabelNode(text: "Time: \(timeString)")
        timeLabel.fontName = "Ethnocentric-Regular"
        timeLabel.fontColor = .green
        timeLabel.fontSize = 48
        timeLabel.position = CGPoint(x: 0, y: -230)
        timeLabel.zPosition = 22
        popUp.addChild(timeLabel)
        
        // Butonlar
        setupLevelCompleteButtons(on: popUp, onRestart: onRestart, onMap: onMap, onNext: onNext)
        
        // Animasyon
        animateLevelCompletePopup(popup: popUp)
    }
    
    private func setupStarsDisplay(on popup: SKSpriteNode, stars: Int) {
        let starSpacing: CGFloat = 240
        let startX: CGFloat = -240
        
        for i in 0..<3 {
            let star: SKSpriteNode
            
            if i < stars {
                switch stars {
                case 1:
                    star = SKSpriteNode(imageNamed: "Star_03")
                case 2:
                    star = SKSpriteNode(imageNamed: i == 0 ? "Star_03" : "Star_03")
                case 3:
                    star = SKSpriteNode(imageNamed: "Star_03")
                default:
                    star = SKSpriteNode(imageNamed: "Star_01")
                }
            } else {
                star = SKSpriteNode(imageNamed: "Star_01")
            }
            
            star.size = CGSize(width: 200, height: 200)
            star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: 175)
            star.zPosition = 22
            popup.addChild(star)
            
            if i < stars {
                let rotateAction = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
                let repeatAction = SKAction.repeatForever(rotateAction)
                star.run(repeatAction)
            }
        }
        
        let starMessage = getStarMessage(stars: stars)
        let messageLabel = SKLabelNode(text: starMessage)
        messageLabel.fontName = "Ethnocentric-Regular"
        messageLabel.fontSize = 32
        messageLabel.fontColor = getStarColor(stars: stars)
        messageLabel.position = CGPoint(x: 0, y: 5)
        messageLabel.zPosition = 22
        popup.addChild(messageLabel)
    }
    
    private func getStarMessage(stars: Int) -> String {
        switch stars {
        case 3:
            return "PERFECT! NO ENEMY ESCAPED!"
        case 2:
            return "WELL DONE! MOST ENEMIES DEFEATED"
        case 1:
            return "GOOD EFFORT! KEEP IMPROVING"
        case 0:
            return "TRY AGAIN! YOU CAN DO BETTER"
        default:
            return "LEVEL COMPLETED"
        }
    }
    
    private func getStarColor(stars: Int) -> UIColor {
        switch stars {
        case 3:
            return .systemGreen
        case 2:
            return .systemYellow
        case 1:
            return .systemOrange
        case 0:
            return .systemRed
        default:
            return .white
        }
    }
    
    private func setupLevelCompleteButtons(on popup: SKSpriteNode, onRestart: @escaping () -> Void, onMap: @escaping () -> Void, onNext: @escaping () -> Void) {
        // Restart butonu
        let restartButton = SKSpriteNode(imageNamed: "Replay_BTN")
        restartButton.size = CGSize(width: 190, height: 190)
        restartButton.position = CGPoint(x: -280, y: -440)
        restartButton.zPosition = 22
        restartButton.name = "levelCompleteRestart"
        popup.addChild(restartButton)
        
        // Map butonu
        let mapButton = SKSpriteNode(imageNamed: "Menu_BTN")
        mapButton.size = CGSize(width: 190, height: 190)
        mapButton.position = CGPoint(x: 0, y: -440)
        mapButton.zPosition = 22
        mapButton.name = "levelCompleteMap"
        popup.addChild(mapButton)
        
        // Next butonu
        let nextButton = SKSpriteNode(imageNamed: "Forward_BTN")
        nextButton.size = CGSize(width: 190, height: 190)
        nextButton.position = CGPoint(x: 280, y: -440)
        nextButton.zPosition = 22
        nextButton.name = "levelCompleteNext"
        popup.addChild(nextButton)
        
        storeLevelCompleteCallbacks(onRestart: onRestart, onMap: onMap, onNext: onNext)
    }
    
    private func animateLevelCompletePopup(popup: SKSpriteNode) {
        popup.alpha = 0
        popup.setScale(0.1)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let group = SKAction.group([fadeIn, scaleUp])
        
        popup.run(group)
    }
    
    // Callback'leri store etmek için property'ler
    private var restartCallback: (() -> Void)?
    private var mapCallback: (() -> Void)?
    private var nextCallback: (() -> Void)?
    
    private func storeLevelCompleteCallbacks(onRestart: @escaping () -> Void, onMap: @escaping () -> Void, onNext: @escaping () -> Void) {
        restartCallback = onRestart
        mapCallback = onMap
        nextCallback = onNext
    }
    
    func hideLevelCompletePopup() {
        scene?.childNode(withName: "LevelCompleteOverlay")?.removeFromParent()
        scene?.childNode(withName: "LevelCompletePopup")?.removeFromParent()
        
        restartCallback = nil
        mapCallback = nil
        nextCallback = nil
    }
    
    func handleLevelCompleteTouch(at point: CGPoint) -> Bool {
        guard let scene = scene else { return false }
        guard scene.childNode(withName: "LevelCompletePopup") != nil else { return false }
        
        let touchedNodes = scene.nodes(at: point)
        
        for node in touchedNodes {
            switch node.name {
            case "levelCompleteRestart":
                animateButtonPress(node) { [weak self] in
                    self?.restartCallback?()
                }
                return true
                
            case "levelCompleteMap":
                animateButtonPress(node) { [weak self] in
                    self?.mapCallback?()
                }
                return true
                
            case "levelCompleteNext":
                animateButtonPress(node) { [weak self] in
                    self?.nextCallback?()
                }
                return true
                
            default:
                continue
            }
        }
        
        return false
    }
    
    private func animateButtonPress(_ button: SKNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        
        button.run(sequence) {
            completion()
        }
    }
    
    // MARK: - Cleanup
    
    func cleanUp() {
        stopTimer()
        
        // Sol üst UI'ları temizle
        healthContainer?.removeFromParent()
        armorContainer?.removeFromParent()
        
        // Sağ üst UI'ları temizle
        scoreContainer?.removeFromParent()
        timerContainer?.removeFromParent()
        
        // Game over elementlerini temizle
        gameOverLabel?.removeFromParent()
        restartLabel?.removeFromParent()
        scene?.childNode(withName: "gameOverOverlay")?.removeFromParent()
        
        // Referansları temizle
        healthContainer = nil
        armorContainer = nil
        scoreContainer = nil
        timerContainer = nil
        healthLabel = nil
        armorLabel = nil
        scoreLabel = nil
        timerLabel = nil
        gameOverLabel = nil
        restartLabel = nil
        
        // Değerleri sıfırla
        currentScore = 0
        currentHealth = 10
        currentArmor = 5
        currentGameTime = 0
        isTimerRunning = false
    }
    
    func cleanUpGameOver() {
        gameOverLabel?.removeFromParent()
        restartLabel?.removeFromParent()
        scene?.childNode(withName: "gameOverOverlay")?.removeFromParent()
        
        gameOverLabel = nil
        restartLabel = nil
    }
    
    // MARK: - Getters
    
    var score: Int {
        return currentScore
    }
    
    var currentTime: TimeInterval {
        return currentGameTime
    }
    
    var formattedTime: String {
        return formatTime(currentGameTime)
    }
}
