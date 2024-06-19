//
//  Character.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import SpriteKit

class Character: SKSpriteNode{
    var health: Double = 1{
        didSet{
            updateHealth()
        }
    }
    var heart: SKSpriteNode

    
    init(node:SKNode, scene: SKScene) {
        let texture = SKTexture(imageNamed: String(node.name?.dropLast() ?? ""))
        let size = CGSize(width: 248, height: 351)
        let color = UIColor.clear
        
        heart = SKSpriteNode(imageNamed: "heart-on")
        
        super.init(texture: texture, color: color, size: size)
        self.position = node.position
        self.name = node.name
        
        heart.setScale(0.5)
        heart.position = CGPoint(x: position.x, y: position.y + 220)
        
        
        scene.addChild(heart)
        
        physicsBody = SKPhysicsBody(texture: texture, size: size)
        physicsBody!.isDynamic = false
        physicsBody!.allowsRotation = false
        physicsBody!.pinned = false
        physicsBody!.affectedByGravity = true
    }
    
    override var position: CGPoint{
        didSet{
            heart.position = CGPoint(x: position.x, y: position.y + 220)
        }
    }
    
    private func updateHealth(){
        if health == 1 {
            heart.texture = SKTexture(imageNamed: "heart-on")
        }else if health == 0.5{
            heart.texture = SKTexture(imageNamed: "heart-half")
        }else{
            heart.texture = SKTexture(imageNamed: "heart-off")
            heart.removeFromParent()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
