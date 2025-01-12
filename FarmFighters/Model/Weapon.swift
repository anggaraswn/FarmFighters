//
//  Weapon.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import SpriteKit

class Weapon: SKSpriteNode{
    var damage: Double
    var type: WeaponType
    var playerTurn: PlayerTurn
    
    init(type: WeaponType, playerTurn: PlayerTurn) {
        self.type = type
        self.playerTurn = playerTurn
        self.damage = type == .basic ? 0.5 : 1
        let texture = playerTurn == .player1 ? SKTexture(imageNamed: type == .basic ? "potato" : "potato-bomb") : SKTexture(imageNamed: type == .basic ? "tomato" : "tomato-bomb")
        //        let texture = SKTexture(imageNamed: type == .orange ? "Orange" : "bom")
        let size = CGSize(width: 150, height: 260)
        let color = UIColor.clear
        super.init(texture: texture, color: color, size: size)
        
        
        physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: 150, height: 150))
        physicsBody?.isDynamic = true
        physicsBody?.allowsRotation = true
        physicsBody?.affectedByGravity = true
        physicsBody?.mass = 0.3
        physicsBody?.density = 0.3
        
        physicsBody?.categoryBitMask = PhysicsCategory.Orange
        physicsBody?.collisionBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Character
        physicsBody?.contactTestBitMask = PhysicsCategory.Obstacle | PhysicsCategory.Character
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")
        
    }
}
