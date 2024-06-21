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
        self.damage = type == .orange ? 0.5 : 1
        let texture = SKTexture(imageNamed: type == .orange ? "Orange" : "bom")
        let size = texture.size()
        let color = UIColor.clear
        super.init(texture: texture, color: color, size: size)
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")
        
    }
}
