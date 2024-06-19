//
//  Weapon.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import SpriteKit

class Weapon: SKSpriteNode{
    var damage: Int
    
    init(texture: String, damage: Int) {
        self.damage = damage
        let texture = SKTexture(imageNamed: texture)
        let size = texture.size()
        let color = UIColor.clear
        
        super.init(texture: texture, color: color, size: size)
        
        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")
        
    }
}
