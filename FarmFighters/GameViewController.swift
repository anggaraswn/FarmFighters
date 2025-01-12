//
//  GameViewController.swift
//  Euphorience
//
//  Created by Anggara Satya Wimala Nelwan on 07/06/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenu(size: CGSize(width: 2388, height: 1668))
                
//                SKScene(fileNamed: "landingPage") 
//            {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
//            }
            
            view.ignoresSiblingOrder = true
            
//            view.showsFPS = true
//            view.showsNodeCount = true
        }
    }

//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
    
    override var shouldAutorotate: Bool{
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
