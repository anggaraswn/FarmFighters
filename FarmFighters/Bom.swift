//
//  Bom.swift
//  FarmFighters
//
//  Created by Retno Shintya Hariyani on 19/06/24.
//

import SpriteKit

class Bom: SKSpriteNode {
    init() {
        let texture = SKTexture(imageNamed: "bom")
        let size = texture.size()
        let color = UIColor.clear

        super.init(texture: texture, color: color, size: size)

        physicsBody = SKPhysicsBody(circleOfRadius: size.width / 2)
}

required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented")
    
    }
}
