//
//  Obstacle.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import SpriteKit

class Obstacle {
    //    var obsHealth: Double = 1
    //    var hits: Int = 0

    var node: SKSpriteNode
    private var _position: CGPoint
        
    var position: CGPoint {
        get {
            return _position
        }
        set {
            _position = newValue
            node.position = newValue
        }
    }
        
        
    init(node: SKSpriteNode) {
        self.node = node
        self._position = node.position
    }
        
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
