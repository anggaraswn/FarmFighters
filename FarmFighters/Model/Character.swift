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
        heart = SKSpriteNode(imageNamed: "Heart-on")
        heart.setScale(0.05)
        heart.position = CGPoint(x: _position.x, y: _position.y + 220)
        heart.zPosition = 1
        
        scene.addChild(heart)
    }
    
    private func updateHealth(){
        if health == 1 {
            heart.texture = SKTexture(imageNamed: "Heart-on")
        }else if health == 0.5{
            heart.texture = SKTexture(imageNamed: "Heart-half")
        }else{
            heart.texture = SKTexture(imageNamed: "Heart-off")
            heart.removeFromParent()
        }
    }
    
    func updateHeartPosition() {
            heart.position = CGPoint(x: node.position.x, y: node.position.y + 220)
        }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
