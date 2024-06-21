//
//  Character.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import SpriteKit

class Character{
    var health: Double = 1{
        didSet{
            updateHealth()
        }
    }
    var heart: SKSpriteNode
    var node: SKSpriteNode
    private var _position: CGPoint
    
    var position: CGPoint {
        get {
            return _position
        }
        set {
            _position = newValue
            node.position = newValue
            heart.position = CGPoint(x: newValue.x, y: newValue.y + 220)
        }
    }
    
    
    init(node: SKSpriteNode, scene: SKScene) {
        self.node = node
        self._position = node.position
        heart = SKSpriteNode(imageNamed: "heart-on")
        heart.setScale(0.5)
        heart.position = CGPoint(x: _position.x, y: _position.y + 220)
        heart.zPosition = 1
        
        scene.addChild(heart)
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
