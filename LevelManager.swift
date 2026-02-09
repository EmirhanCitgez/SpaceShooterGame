//
//  LevelManager.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 20/08/2025.
//

import SpriteKit

class LevelManager {
    //Şuan hangi level'deyiz
    private(set) var currentLevel: Int = 0
    
    //Level Konfigrasyonları
    struct LevelConfig {
        let enemies: [(type: EnemyType, count: Int)]
    }
    
    //Bütün level cofig'leri burada tutulacak
    private var levels: [LevelConfig] = []
    
    init() {
        setupLevels()
    }
    
    private func setupLevels() {
        levels = [
            LevelConfig(enemies: [(.scout, 5)]),
            LevelConfig(enemies: [(.scout, 3), (.bomber, 2)]),
            LevelConfig(enemies: [(.bomber, 5), (.heavyCrusier, 1)]),
            LevelConfig(enemies: [(.scout, 5), (.bomber, 3), (.heavyCrusier, 2)])
        ]
    }
    
    func startLevel(_ index: Int) -> LevelConfig? {
        // Buton 1-based, array 0-based olduğu için index-1
        let arrayIndex = index - 1
        guard arrayIndex >= 0, arrayIndex < levels.count else {
            print("Invalid level index: \(index). Available levels: 1-\(levels.count)")
            return nil
        }
        currentLevel = index
        print("Starting level \(index) with config: \(levels[arrayIndex].enemies)")
        return levels[arrayIndex]
    }
    
    func nextLevel() -> LevelConfig? {
        return startLevel(currentLevel + 1)
    }
    
    
}
