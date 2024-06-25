//
//  SKAction+Ext.swift
//  FarmFighters
//
//  Created by Rania Pryanka Arazi on 25/06/24.
//

import SpriteKit


// global variable
private let keyEffect = "keyEffect"
var effectEnabled: Bool = {
    return  !UserDefaults.standard.bool(forKey: keyEffect)
}() {
    didSet {
        let value = !effectEnabled
        UserDefaults.standard.set(value,forKey: keyEffect)
        
        if value {
            SKAction.stop()
        }
    }
}


extension SKAction {
    class func playSoundFileNamed(_ fileNamed: String) -> SKAction {
        if !effectEnabled {
            return SKAction()
        }
        
        return SKAction.playSoundFileNamed(fileNamed, waitForCompletion: false)
    }
}
