//
//  MainMenu.swift
//  FarmFighters
//
//  Created by Rania Pryanka Arazi on 26/06/24.
//

import SpriteKit

class MainMenu: SKScene{
    
    let audioManager = SKTAudio.sharedInstance()
    
    func landingPage() {
        let lpNode = SKSpriteNode(imageNamed: "LandingPage")
        lpNode.zPosition = -1.0
        lpNode.anchorPoint = .zero
        lpNode.position = .zero
        
        lpNode.size = CGSize(width: 2388, height: 1688)
        addChild(lpNode)
    }
    
    func setPlay() {
        // tambahkan graphic setting awalnya
        let play = SKSpriteNode(imageNamed: "playButton")
        play.name = "play"
        play.setScale(0.9)
        play.zPosition = 10.0
        play.position = CGPoint(x: size.width/2.0, y: size.height/2.0 + play.size.height/2.0 - 450.0)
        
        addChild(play)
        
        // Create the pulsing animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.6)
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.6)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        // Run the pulsing animation on the play button
        play.run(repeatPulse)
        
    }
    
    override func didMove(to view: SKView) {
        
        //add landing page
        landingPage()
        
        
        //play button
        setPlay()
        
        //bg music
        audioManager.playBGMusic("musicLevel1.mp3", volume: 0.2)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // hanya dijalankan kalo ada touch
        guard let touch = touches.first else {
            return
        }
        // tentukan lokasi touch
        let node = atPoint(touch.location(in: self))
        
        if node.name == "play" {
            let texture = SKTexture(imageNamed: "first")
            let spriteNode = SKSpriteNode(texture: texture)
            spriteNode.anchorPoint = anchorPoint
            spriteNode.zPosition = 150
            spriteNode.alpha = 0.0
            
            addChild(spriteNode)
            
            let fadeIn = SKAction.fadeIn(withDuration: 1.0)
            spriteNode.run(fadeIn)
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                let changeTexture = SKAction.run {
                    spriteNode.texture = SKTexture(imageNamed: "second")
                }
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                let sequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])
                spriteNode.run(sequence)
            }
            
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                let changeTexture = SKAction.run {
                    spriteNode.texture = SKTexture(imageNamed: "third")
                }
                let fadeIn = SKAction.fadeIn(withDuration: 1.0)
                let sequence = SKAction.sequence([fadeOut, changeTexture, fadeIn])
                spriteNode.run(sequence)
            }
            
            Timer.scheduledTimer(withTimeInterval: 15, repeats: false) { _ in
                let fadeOut = SKAction.fadeOut(withDuration: 1.0)
                let changeScene = SKAction.run {
                    if let scene = GameScene.loadRound(round: 1) {
                        scene.scaleMode = .aspectFill
                        if let view = self.view {
                            view.presentScene(scene)
                        }
                    }
                }
                let sequence = SKAction.sequence([fadeOut, changeScene])
                spriteNode.run(sequence)
            }
        }
    }

    
    
}
