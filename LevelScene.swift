//
//  LevelScene.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 18/08/2025.
//

import SpriteKit

class LevelScene: SKScene {
    
    private var titleLabel: SKLabelNode!
    private var background: SKSpriteNode!
    private var levelsBackground: SKSpriteNode!
    private var backButton: SKSpriteNode!
    
    var isAnimating = false
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupUI()
        setupLevelButtons()
    }
    
    private func setupBackground() {
        background = SKSpriteNode(imageNamed: "background4")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        background.size = CGSize(width: frame.width, height: frame.height)
        background.zPosition = -5
        addChild(background)
    }
    
    private func setupUI() {
        // Levels Background
        levelsBackground = SKSpriteNode(imageNamed: "Window")
        levelsBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        levelsBackground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        levelsBackground.size = CGSize(width: frame.width/1.03, height: frame.height/1.9)
        levelsBackground.zPosition = 0
        addChild(levelsBackground)
        
        // Game Title
        titleLabel = SKLabelNode(text: "LEVELS")
        titleLabel.fontName = "Ethnocentric-Regular"
        titleLabel.fontSize = 40
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 182)
        titleLabel.zPosition = 5
        levelsBackground.addChild(titleLabel)
        
        // Back Button
        backButton = SKSpriteNode(imageNamed: "Backward_BTN")
        backButton.size = CGSize(width: 62, height: 62)
        backButton.position = CGPoint(x: frame.width/10, y: frame.height/1.15)
        backButton.name = "backButton"
        backButton.zPosition = 5
        addChild(backButton)
    }
    
    private func setupLevelButtons() {
        let buttonSize = CGSize(width: 66, height: 66)
        let spacingX: CGFloat = 90
        let spacingY: CGFloat = 132
        let buttonCount: Int = 20

        for i in 0..<buttonCount {
            let levelButton = SKSpriteNode(imageNamed: "Dot")
            levelButton.name = "level\(i+1)"
            levelButton.size = buttonSize
            
            let levelLabel = SKLabelNode(text: "\(i+1)")
            levelLabel.fontSize = 30
            levelLabel.fontName = "Ethnocentric-Regular"
            levelLabel.zPosition = 6
            levelLabel.position = CGPoint(x: 0, y: -10)
            levelButton.addChild(levelLabel)

            let column = i % 4
            let row = (i / 4) % 3
            let page = i / 12

            let x = (CGFloat(column) - 1.5) * spacingX + CGFloat(page) * 400
            let y = CGFloat(110) - CGFloat(row) * spacingY

            levelButton.position = CGPoint(x: x, y: y)
            levelButton.zPosition = 5
            levelsBackground.addChild(levelButton)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self)
        let touchedNodes = nodes(at: touchLocation)
        
        for node in touchedNodes {
            if node.name == "backButton" {
                pressBackButton()
                return
            }
            
            if let nodeName = node.name, nodeName.hasPrefix("level") {
                let levelString = String(nodeName.dropFirst(5))
                if let levelIndex = Int(levelString) {
                    pressLevelButton(levelIndex: levelIndex, buttonNode: node)
                    return
                }
            }
        }
    }
    
    private func pressBackButton() {
        guard !isAnimating else { return }
        isAnimating = true
        
        playButtonSound()
        animateButtonPress(backButton) { [weak self] in
            self?.transitionToBack()
        }
    }
    
    private func pressLevelButton(levelIndex: Int, buttonNode: SKNode) {
        guard !isAnimating else { return }
        isAnimating = true
        
        playButtonSound()
        animateButtonPress(buttonNode) { [weak self] in
            self?.transitionToLevel(levelIndex)
        }
    }
    
    private func animateButtonPress(_ button: SKNode, completion: @escaping () -> Void) {
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([scaleDown, scaleUp]), completion: completion)
    }
    
    private func playButtonSound() {
        let clickSound = SKAction.playSoundFileNamed("buttonClick.wav", waitForCompletion: false)
        run(clickSound)
    }
    
    private func transitionToBack() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleOut = SKAction.scale(to: 0.1, duration: 0.5)
        let group = SKAction.group([fadeOut, scaleOut])
        
        run(group) { [weak self] in
            SceneManager.shared.goToMenu()
        }
    }
    
    private func transitionToLevel(_ levelIndex: Int) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleOut = SKAction.scale(to: 0.1, duration: 0.5)
        let group = SKAction.group([fadeOut, scaleOut])
        
        run(group) { [weak self] in
            SceneManager.shared.goToGame(levelIndex: levelIndex)
        }
    }
}
