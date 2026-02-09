//
//  SceneManager.swift (Updated)
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 13/08/2025.
//

import SpriteKit

enum SceneType {
    case menu
    case game
    case map
    case gameOver
    case pause
}

class SceneManager {
    static let shared = SceneManager()
    
    private weak var view: SKView?
    private var currentSceneType: SceneType = .menu
    
    private init() {}
    
    func setup(with view: SKView) {
        self.view = view
    }
    
    //Ana menüye geçiş
    func goToMenu(transition: SKTransition? = nil) {
        guard let view = view else {
            print("View is nil")
            return
        }
        
        print("🏠 Creating MenuScene...")
        let menuScene = MenuScene(size: view.bounds.size)
        menuScene.scaleMode = .aspectFit
            
        let defaultTransition = SKTransition.crossFade(withDuration: 0.5)
            
        view.presentScene(menuScene, transition: transition ?? defaultTransition)
        currentSceneType = .menu
            
        print("🏠 MenuScene presented")
    }
    
    func goToGame(levelIndex: Int, transition: SKTransition? = nil, forceRestart: Bool = false) {
        if !forceRestart {
            guard currentSceneType != .game else { return }
        }
        
        print("🎮 Starting game...")
        
        // GameScene'i .sks dosyasından yükle
        guard let gameScene = GameScene(fileNamed: "GameScene") else {
            print("❌ Failed to load GameScene.sks file")
            
            // .sks dosyası yoksa manuel oluştur
            let manualGameScene = GameScene()
            manualGameScene.size = view?.bounds.size ?? CGSize(width: 375, height: 812)
            manualGameScene.scaleMode = .aspectFit
            
            //Level index'i GameScene'a aktar
            manualGameScene.selectedLevelIndex = levelIndex
            
            let defaultTransition = SKTransition.moveIn(with: .up, duration: 0.7)
            view?.presentScene(manualGameScene, transition: transition ?? defaultTransition)
            currentSceneType = .game
            
            print("🎮 Created GameScene manually")
            return
        }
        
        gameScene.scaleMode = .aspectFit
        
        //level index'i GameScene'a aktar
        gameScene.selectedLevelIndex = levelIndex
        
        let defaultTransition = SKTransition.moveIn(with: .up, duration: 0.7)
        
        view?.presentScene(gameScene, transition: transition ?? defaultTransition)
        currentSceneType = .game
        
        print("🎮 Transitioned to Game Scene")
    }
    
    //Level sayfasına geçiş
    func goToMap(transition: SKTransition? = nil) {
        guard let view = view else {
            print("View is nil")
            return
        }
        
        print("🗺️ Opening Map Scene...")
        
        let mapScene = LevelScene(size: view.bounds.size)
        mapScene.scaleMode = .aspectFit
        
        let defaultTransition = SKTransition.fade(withDuration: 0.5)
        view.presentScene(mapScene, transition: transition ?? defaultTransition)
        currentSceneType = .map
        
        print("🗺️ Map Scene presented")
    }
    
    // Bu fonksiyonu değiştirin:
    func restartGame(transition: SKTransition? = nil) {
        // Mevcut level'ı al
        let currentLevel = getCurrentLevel()
        
        // High score kontrolü ve kaydetme
        saveHighScoreIfNeeded()
        
        goToGame(levelIndex: currentLevel, transition: transition, forceRestart: true)
    }

    // Bu fonksiyonu ekleyin:
    private func getCurrentLevel() -> Int {
        if let gameScene = view?.scene as? GameScene {
            return gameScene.selectedLevelIndex
        }
        return 1 // Default olarak level 1
    }
    
    //Pause menüsü
    func pauseGame() {
        
    }
    
    //Resume game
    func resumeGame() {
        
    }
    
    func saveHighScoreIfNeeded(score: Int? = nil) {
        let currentHighScore = UserDefaults.standard.integer(forKey: "HighScore")
        let gameScore = score ?? getCurrentGameScore()
        
        if gameScore > currentHighScore {
            UserDefaults.standard.set(gameScore, forKey: "HighScore")
            UserDefaults.standard.synchronize()
            
            print("🏆 New High Score: \(gameScore)")
            
            //High Score achievement notification
            //showHighScoreAchievement(score: gameScore)
        }
    }
    
    private func getCurrentGameScore() -> Int {
        //Eğer mevcut sahne GameScene ise score'u al
        if let gameScene = view?.scene as? GameScene {
            return gameScene.uiManager?.score ?? 0
        }
        return 0
    }
    
    private func showHighScoreAchievement(score: Int) {
        // High score başarısı için animasyon/bildirim
    }
    
    var isInGame: Bool {
        return currentSceneType == .game
    }
    
    var isInMenu: Bool {
        return currentSceneType == .menu
    }
    
    //Transition Effects
    static func createFadeTransition(duration: TimeInterval = 0.5) -> SKTransition {
        return SKTransition.crossFade(withDuration: duration)
    }
    
    static func createSlideTransition(direction: SKTransitionDirection, duration: TimeInterval = 0.7) -> SKTransition {
        return SKTransition.push(with: direction, duration: duration)
    }
    
    static func createDoorwayTransition(duration: TimeInterval = 0.8) -> SKTransition {
        return SKTransition.doorway(withDuration: duration)
    }
    
    static func createFlipTransition(direction: SKTransitionDirection, duration: TimeInterval = 1) -> SKTransition {
        return SKTransition.flipHorizontal(withDuration: duration)
    }
}
