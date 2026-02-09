//
//  GameConstants.swift
//  SpaceShooter
//
//  Created by Emirhan Çitgez on 12/08/2025.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 0b1              //1
    static let playerBullet: UInt32 = 0b10       //2
    static let enemy: UInt32 = 0b100             //4
    static let enemyBullet: UInt32 = 0b1000      //8
    static let boundary: UInt32 = 0b10000        //16
}
