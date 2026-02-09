//
//  MenuScene.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 13/08/2025.
//

import SpriteKit

class MenuScene: SKScene {
    
    //UI Elements
    private var titleLabel: SKLabelNode!
    private var playButton: SKSpriteNode!
    private var mapButton: SKSpriteNode!
    private var highScoreLabel: SKLabelNode!
    private var creditsLabel: SKLabelNode!
    
    //Background elements
    private var backgroundSprite: SKSpriteNode!
    private var stars: [SKSpriteNode] = []
    
    //Animation flags
    private var isAnimating = false
    
    override func didMove(to view: SKView) {
        print("🟢 MenuScene loaded successfully!")
        setupBackground()
        setupUI()
        setupAnimation()
        
        playBackgroundmusic()
    }
    
    private func setupBackground() {
        backgroundSprite = SKSpriteNode(imageNamed: "menuBackground2")
        backgroundSprite.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundSprite.size = CGSize(width: frame.width, height: frame.height)
        backgroundSprite.zPosition = -5
        addChild(backgroundSprite)
        
        print("🖼️ Background size: \(frame.width), \(frame.height)")
    }
    
    private func setupUI() {
        //Game Title
        titleLabel = SKLabelNode(text: "Cosmo Clash")
        titleLabel.fontName = "Ethnocentric-Regular"
        titleLabel.fontSize = 42
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: frame.width/2, y: frame.height/1.3)
        titleLabel.zPosition = 10
        
        //Gradient effects for title
        let titleShadow = SKLabelNode(text: "Cosmo Clash")
        titleShadow.fontName = "Ethnocentric-Regular"
        titleShadow.fontSize = 42
        titleShadow.fontColor = .gray
        titleShadow.position = CGPoint(x: 2, y: -2)
        titleShadow.zPosition = 9
        titleLabel.addChild(titleShadow)
        
        addChild(titleLabel)
        
        //Play Button
        playButton = SKSpriteNode(imageNamed: "playButton")
        playButton.size = CGSize(width: 150, height: 45)
        playButton.position = CGPoint(x: frame.width/2, y: frame.height / 2)
        playButton.zPosition = 10
        playButton.name = "playButton"
        addChild(playButton)
        
        //Map Button
        mapButton = SKSpriteNode(imageNamed: "mapButton")
        mapButton.size = CGSize(width: 150, height: 45)
        mapButton.position = CGPoint(x: frame.width/2, y: frame.height / 2.5)
        mapButton.zPosition = 10
        mapButton.name = "mapButton"
        addChild(mapButton)
        
        //High Score
        let highScore = UserDefaults.standard.integer(forKey: "HighScore")
        highScoreLabel = SKLabelNode(text: "High Score: \(highScore)")
        highScoreLabel.fontName = "Ethnocentric-Regular"
        highScoreLabel.fontSize = 16
        highScoreLabel.fontColor = .yellow
        highScoreLabel.position = CGPoint(x:frame.width/2, y: frame.height/1.38)
        highScoreLabel.zPosition = 10
        addChild(highScoreLabel)
        
        //Credits
        creditsLabel = SKLabelNode(text: "Created by Emirhan Çitgez")
        creditsLabel.fontName = "Arial"
        creditsLabel.fontSize = 20
        creditsLabel.fontColor = .lightGray
        creditsLabel.position = CGPoint(x: frame.width/2, y: frame.height/15)
        creditsLabel.zPosition = 10
        addChild(creditsLabel)
        
        //Instructions
        let instructionsLabel = SKLabelNode(text: "Touch and drag to move • Tap to shoot")
        instructionsLabel.fontName = "Ethnocentric-Regular"
        instructionsLabel.fontSize = 10
        instructionsLabel.fontColor = .lightGray
        instructionsLabel.position = CGPoint(x: frame.width/2, y: frame.height/1.1)
        instructionsLabel.zPosition = 10
        addChild(instructionsLabel)
        
    }
    
    private func setupAnimation() {
        //Title pulse animation
        let scaleUp = SKAction.scale(to: 0.8, duration: 2.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 2.0)
        let pulseSequence = SKAction.sequence([scaleUp, scaleDown])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        titleLabel.run(pulseForever)
        
        //Play button glow animation
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 1.5)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let glowSequence = SKAction.sequence([fadeOut, fadeIn])
        let glowForever = SKAction.repeatForever(glowSequence)
        playButton.run(glowForever)
        
        //Map button glow animation
        let fadeOut2 = SKAction.fadeAlpha(to: 0.5, duration: 1.5)
        let fadeIn2 = SKAction.fadeAlpha(to: 1.0, duration: 1.5)
        let glowSequence2 = SKAction.sequence([fadeOut2, fadeIn2])
        let glowForever2 = SKAction.repeatForever(glowSequence2)
        mapButton.run(glowForever2)
        
        //Credits float animation
        let floatUp = SKAction.moveBy(x: 0, y: 20, duration: 3.0)
        let floatDown = SKAction.moveBy(x: 0, y: -20, duration: 3.0)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)
        creditsLabel.run(floatForever)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            
            let touchLocation = touch.location(in: self)
            let touchedNodes = nodes(at: touchLocation)
            
            for node in touchedNodes {
                if node.name == "playButton" {
                    quickPlayPressed()
                    break
                }
                
                if node.name == "mapButton" {
                    clickMapButton()
                    break
                }
            }
    }
        
    
    private func quickPlayPressed() {
            guard !isAnimating else { return }
            isAnimating = true
            
            print("🎮 Quick Play pressed")
            
            //Button press animation
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            
            playButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                self?.transitionToGame()
            }
            
            //Sound Effect
            let clickSound = SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false)
            run(clickSound)
        }
    
    private func clickMapButton() {
            guard !isAnimating else { return }
            isAnimating = true
            
            print("🎮 Quick Play pressed")
            
            //Button press animation
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
            
            mapButton.run(SKAction.sequence([scaleDown, scaleUp])) { [weak self] in
                self?.transitionToMap()
            }
            
            //Sound Effect
            let clickSound = SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false)
            run(clickSound)
        }
    
    private func transitionToGame() {
        //Transition animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleOut = SKAction.scale(to: 0.1, duration: 0.5)
        let group = SKAction.group([fadeOut, scaleOut])
        
        run(group) { [weak self] in
            self?.startGame()
        }
    }
    
    private func transitionToMap() {
        //Transition animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleOut = SKAction.scale(to: 0.1, duration: 0.5)
        let group = SKAction.group([fadeOut, scaleOut])
        
        run(group) { [weak self] in
            self?.showLevels()
        }
    }
    
    private func startGame() {
        //Load GameScene
        SceneManager.shared.goToGame(levelIndex: 1)
    }
    
    private func showLevels() {
        SceneManager.shared.goToMap()
    }
    
    private func playBackgroundmusic() {
        // Eğer background müzik dosyanız varsa
        if let musicURL = Bundle.main.url(forResource: "menuBackgroundMusic", withExtension: "mp3") {
                let backgroundMusic = SKAudioNode(url: musicURL)
                backgroundMusic.autoplayLooped = true
                addChild(backgroundMusic)
            } else {
                print("Müzik dosyası bulunamadı!")
            }
    }
    
    override func update(_ currentTime: TimeInterval) {
        let currentHighScore = UserDefaults.standard.integer(forKey: "HighScore")
        if !highScoreLabel.text!.contains("\(currentHighScore)") {
            highScoreLabel.text = "High Score: \(currentHighScore)"
        }
        
    }
}
