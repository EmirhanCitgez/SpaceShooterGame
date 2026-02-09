//
//  EffectsManager.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 13/08/2025.
//

import SpriteKit

class EffectsManager {
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    //Patlama efekti gösterir
    func showExplosion(at position: CGPoint, size: CGSize) {
        guard let scene = scene else { return }
        
        var textures: [SKTexture] = []
        
        // 11 kareyi sırayla diziye ekle
        for i in 1...11 {
            let textureName = "boom\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        
        let explosion = SKSpriteNode(texture: textures.first)
        explosion.position = position
        explosion.zPosition = 10
        
        explosion.size = CGSize(width: size.width * 1.8, height: size.height * 1.8)
        
        scene.addChild(explosion)
        
        // Animasyonu oluştur
        let animation = SKAction.animate(with: textures, timePerFrame: 0.05, resize: false, restore: false)
        let remove = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([animation, remove]))
        
        playExplosionSound()
    }
    
    func showSmallExplosion(at position: CGPoint) {
        showExplosion(at: position, size: CGSize(width: 60, height: 60))
    }
    
    func showLargeExplosion(at position: CGPoint, size: CGSize) {
        guard let scene = scene else { return }
        
        var textures: [SKTexture] = []
        
        // 11 kareyi sırayla diziye ekle
        for i in 1...11 {
            let textureName = "boom\(i)"
            let texture = SKTexture(imageNamed: textureName)
            textures.append(texture)
        }
        
        let explosion = SKSpriteNode(texture: textures.first)
        explosion.position = position
        explosion.zPosition = 10
        
        explosion.size = CGSize(width: size.width * 2.5, height: size.height * 2.5)
        
        scene.addChild(explosion)
        
        // Animasyonu oluştur
        let animation = SKAction.animate(with: textures, timePerFrame: 0.08, resize: false, restore: false)
        let remove = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([animation, remove]))
        
        playExplosionSound()
    }
    
    private func playExplosionSound() {
        guard let scene = scene else { return }
        
        let explosionSound = SKAction.playSoundFileNamed("DeathFlash.mp3", waitForCompletion: false)
        scene.run(explosionSound)
    }
    
    //Ekran titreme efekti
    func shakeScreen(duration: TimeInterval = 0.3, intensity: CGFloat = 10.0) {
        guard let scene = scene else { return }
        
        if let camera = scene.camera {
            let originalPosition = camera.position
            
            let shake = SKAction.customAction(withDuration: duration) { node, elapsedTime in
                let randomX = CGFloat.random(in: -intensity...intensity)
                let randomY = CGFloat.random(in: -intensity...intensity)
                node.position = CGPoint(x: originalPosition.x + randomX, y: originalPosition.y + randomY)
            }
            
            let resetPosition = SKAction.run {
                camera.position = originalPosition
            }
            
            camera.run(SKAction.sequence([shake, resetPosition]))
        }
    }
    
    //Ekran flash efekti (hasar alındığında)
    func flashScreen(color: UIColor = .red, duration: TimeInterval = 0.4) {
        guard let scene = scene else { return }
        
        let flashNode = SKSpriteNode(color: color, size: scene.size)
        flashNode.position = CGPoint(x: 0, y: 0)
        flashNode.zPosition = 100
        flashNode.alpha = 0.3
        
        scene.addChild(flashNode)
        
        let fadeOut = SKAction.fadeOut(withDuration: duration)
        let remove = SKAction.removeFromParent()
        
        flashNode.run(SKAction.sequence([fadeOut, remove]))
    }
    
    //Yıldız parçacık efekti
    func addStarField() {
        //Background için moving stars
    }
    
    //Düşman öldüğünde parçacık efekti
    func showDestructionParticles() {
        // İleride eklenecek - düşman yok olurken parçacıklar
    }
}
