//
//  BulletManager.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 13/08/2025.
//

import SpriteKit

class BulletManager{
    
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func createPlayerBullet(at position: CGPoint) {
        guard let scene = scene else { return }
        
        //Assetten mermi oluşturma
        let bullet = SKSpriteNode(imageNamed: "Bullet")
        bullet.size = CGSize(width: 46, height: 80)
        bullet.position = position
        bullet.name = "bullet"
        bullet.zPosition = 9
        
        //Mermi için çarpışma fiziği
        let realBulletSize = CGSize(width: bullet.size.width * 0.55, height: bullet.size.height * 0.65)
        bullet.physicsBody = SKPhysicsBody(rectangleOf: realBulletSize)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.playerBullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        
        scene.addChild(bullet)
        
        let moveAction = SKAction.moveBy(x: 0, y: scene.size.height, duration: 1.8)
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    func fireEnemyBullet(from enemy: SKSpriteNode) {
        guard let scene = scene else { return }
        
        let enemyScoutBullet = SKSpriteNode(imageNamed: "enemyScoutBullet")
        enemyScoutBullet.size = CGSize(width: 140, height: 70)
        enemyScoutBullet.zRotation = -.pi/2
        enemyScoutBullet.position = CGPoint(x: enemy.position.x, y: enemy.position.y - enemy.size.height / 1.4 )
        enemyScoutBullet.name = "enemyBullet" // GameScene ile uyumlu olması için değiştirildi
        enemyScoutBullet.zPosition = 2
        
        let realEnemyScoutBulletSize = CGSize(width: enemyScoutBullet.size.width * 0.7, height: enemyScoutBullet.size.height * 0.7)
        enemyScoutBullet.physicsBody = SKPhysicsBody(rectangleOf: realEnemyScoutBulletSize)
        enemyScoutBullet.physicsBody?.affectedByGravity = false
        enemyScoutBullet.physicsBody?.isDynamic = true
        enemyScoutBullet.physicsBody?.categoryBitMask = PhysicsCategory.enemyBullet
        enemyScoutBullet.physicsBody?.contactTestBitMask = PhysicsCategory.player
        enemyScoutBullet.physicsBody?.collisionBitMask = PhysicsCategory.none
        enemyScoutBullet.physicsBody?.usesPreciseCollisionDetection = true
        
        scene.addChild(enemyScoutBullet)
        
        let moveBulletDown = SKAction.moveBy(x: 0, y: -scene.size.height, duration: 1.8)
        let removeAction = SKAction.removeFromParent()
        enemyScoutBullet.run(SKAction.sequence([moveBulletDown, removeAction]))
    }
    
    func removeAllBullets() {
        // Player bullets
        scene?.enumerateChildNodes(withName: "bullet") { node, _ in
            node.removeFromParent()
        }
        
        // Enemy bullets - Enemy.swift ile tutarlı olması için "enemyBullet" kullan
        scene?.enumerateChildNodes(withName: "enemyBullet") { node, _ in
            node.removeFromParent()
        }
    }
    
    func removePlayerBullets() {
        scene?.enumerateChildNodes(withName: "bullet") { node, _ in
            node.removeFromParent()
        }
    }
    
    func removeEnemyBullets() {
        // Enemy bullets - tutarlılık için "enemyBullet" kullan
        scene?.enumerateChildNodes(withName: "enemyBullet") { node, _ in
            node.removeFromParent()
        }
    }
}
