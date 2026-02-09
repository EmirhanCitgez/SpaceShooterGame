//
//  Player.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 11/08/2025.
//

import SpriteKit

class Player {
    
    let sprite: SKSpriteNode
    private(set) var lives: Int
    private(set) var armor: Int
    private(set) var isAlive: Bool
    private let originalPosition: CGPoint
    weak var scene: GameScene?
    
    init(texture: String, position: CGPoint, scene: GameScene) {
        
        //1.Sprite oluştur
        self.sprite = SKSpriteNode(imageNamed: texture)
        
        //2-4. Diğer özellikler
        self.lives = 9999
        self.armor = 0
        self.isAlive = true
        self.originalPosition = position
        
        //5.Scene referansı
        self.scene = scene
        
        //6.Sprite'ı ayarla
        setupSprite(at: position)
    }
    
    private func setupSprite(at position: CGPoint) {
        //1.Temel Sprite ayarları
        sprite.position = position
        sprite.zPosition = 11
        
        //2.Size ayarlama
        let originalTexture = SKTexture(imageNamed: "player1")
        sprite.size = CGSize(
            width: originalTexture.size().width * 1.75,
            height: originalTexture.size().height * 1.85)
        
        //3.Physics Body
        sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.isDynamic = true
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.player
        sprite.physicsBody?.collisionBitMask = PhysicsCategory.none
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.enemyBullet
        
    }
    
    func moveToPosition(_ position: CGPoint) {
        //Ekran sınırları kontrolü
        let boundedPosition = clampToScreenBounds(position)
        
        //Hareket animasyonu
        //let moveAction = SKAction.move(to: boundedPosition, duration: 0.1)
        //sprite.run(moveAction)
        
        sprite.position = boundedPosition
    }
    
    private func clampToScreenBounds(_ position: CGPoint) -> CGPoint {
        guard let scene = scene else { return position}
        
        let halfWidth = sprite.size.width / 2
        let halfHeight = sprite.size.height / 2
        
        let minX = -scene.size.width/2 + halfWidth
        let maxX = scene.size.width/2 - halfWidth
        let minY = -scene.size.height/2 + halfHeight
        let maxY = scene.size.height/2 - halfHeight
        
        return CGPoint(
            x: max(minX, min(maxX, position.x)),
            y: max(minY, min(maxY, position.y))
        )
    }
    
    func resetToOriginalPosition() {
        sprite.position = originalPosition
    }
    
    func fireBullet() {
        guard isAlive, let scene = scene else { return }
        
        //Bullet pozisyonunu hesapla
        let bulletPosition = CGPoint(
            x: sprite.position.x,
            y: sprite.position.y + sprite.size.height / 1.65
        )
        
        //Scene'den bullet oluşturmasını iste
        scene.bulletManager.createPlayerBullet(at: bulletPosition)
        
    }
    
    func startFiring() {
        guard isAlive else {return}
        
        let fireAction = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in self?.fireBullet()},
                SKAction.wait(forDuration: 0.45)
            ])
        )
        sprite.run(fireAction, withKey: "firing")
    }
    
    func stopFiring() {
        sprite.removeAction(forKey: "firing")
    }
    
    //Health Methods
    func takeDamage() {
        guard isAlive else { return }
        
        if armor > 0 {
            armor -= 1
            if armor < 0 { armor = 0 } // Negatif değer engeli
            scene?.uiManager.updateArmorDot(armor)
        } else {
            lives -= 1
            if lives < 0 { lives = 0 }
            scene?.uiManager.updateLivesDots(lives)
            
            if lives <= 0 {
                die()
            } else {
                becomeInvulnerable()
            }
        }
    }
    
    private func die() {
        isAlive = false
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.none
        sprite.physicsBody?.categoryBitMask = PhysicsCategory.none
        
        scene?.playerDidDie(at: sprite.position, size: sprite.size)
        
    }
    
    private func becomeInvulnerable() {
        sprite.physicsBody?.contactTestBitMask = PhysicsCategory.none
        
        let wait = SKAction.wait(forDuration: 1.0)
        let enubleContact = SKAction.run {
            self.sprite.physicsBody?.contactTestBitMask = PhysicsCategory.enemyBullet
        }
        sprite.run(SKAction.sequence([wait, enubleContact]))
    }
}
