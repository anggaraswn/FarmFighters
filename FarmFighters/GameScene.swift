//
//  GameScene.swift
//  Euphorience
//
//  Created by Anggara Satya Wimala Nelwan on 07/06/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var orange: Orange?
    var touchStart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    var boundary = SKNode()
    var numOfLevels: UInt32 = 6
    var pathDots = [SKShapeNode]() // Array to hold the dot nodes
    let maxDragDistance: CGFloat = 150.0
    var turn: UInt32 = 1
    
    var chicken: SKSpriteNode!
    var duck: SKSpriteNode!
    var selectedNode: SKSpriteNode?
    var token = 1
    var touchStartTime: TimeInterval?
    var isNodeReadyToMove = false {
        didSet{
            cancelIcon.isHidden = !isNodeReadyToMove
        }
    }
    var initialNodePosition: CGPoint?
    var cancelIcon: SKSpriteNode!
    
    var cameraNode = SKCameraNode()
    var initialCameraPosition: CGPoint = .zero
    var opponentCameraPosition: CGPoint = .zero
    var orangeStoppedTime: TimeInterval?
    var isOrangeShot = false
    var canShoot = true
    
    var lifeTroops: Int = 3
    var lifeNodes: [SKSpriteNode] = []
    var playableRect: CGRect = CGRect.zero
    
    func setupPlayableRect() {
        // Get the screen size
        let screenSize = UIScreen.main.bounds.size
        
        // Define the playable rect based on the screen size
        playableRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
    }
    
    func setupLifePos(_ node: SKSpriteNode, i: CGFloat, j: CGFloat) {
        let width = playableRect.width
        let height = playableRect.height
        
        print(width)
        print(height)

        node.setScale(0.4)
        node.zPosition = 50.0

        let nodeWidth = node.size.width * node.xScale
        let nodeHeight = node.size.height * node.yScale
        let padding: CGFloat = 100.0
        
        node.position = CGPoint(x: playableRect.minX + (nodeWidth + padding) * i,
                                       y: playableRect.maxY - (nodeHeight + padding) * (j + 1))
    }
    
    func setupLife() {
        // Call this function to set the playable rect
        setupPlayableRect()
        
        // ambil gambar (load images)
        let node1 = SKSpriteNode(imageNamed: "heart-on")
        let node2 = SKSpriteNode(imageNamed: "heart-on")
        let node3 = SKSpriteNode(imageNamed: "heart-on")

        // Set positions
        setupLifePos(node1, i: 1.0, j: -2.0)
        setupLifePos(node2, i: 2.0, j: -2.0)
        setupLifePos(node3, i: 3.0, j: -2.0)

        // Add nodes to the scene
        self.addChild(node1)
        self.addChild(node2)
        self.addChild(node3)

        // Append nodes to lifeNodes array
        lifeNodes.append(node1)
        lifeNodes.append(node2)
        lifeNodes.append(node3)
    }
    
    func createCharacter(){
        chicken = (childNode(withName: "chicken") as! SKSpriteNode)
        chicken.physicsBody!.categoryBitMask = PhysicsCategory.Character
        chicken.physicsBody!.contactTestBitMask = PhysicsCategory.Orange
        
        duck = (childNode(withName: "duck") as! SKSpriteNode)
        duck.physicsBody!.categoryBitMask = PhysicsCategory.Character
        duck.physicsBody!.contactTestBitMask = PhysicsCategory.Orange
    }
    
    override func didMove(to view: SKView) {
        shapeNode.lineWidth = 40
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        // Set the contact delegate
        physicsWorld.contactDelegate = self
        
        // Setup the boundaries
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
        boundary.position = .zero
        addChild(boundary)
        
        createCharacter()
        setupLife()
        
        cancelIcon = SKSpriteNode(imageNamed: "cancelIcon")
        cancelIcon.name = "cancelIcon"
        cancelIcon.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        cancelIcon.isHidden = true // Hide the cancel icon initially
        addChild(cancelIcon)
        
        // Add the camera to the scene
        addChild(cameraNode)
        camera = cameraNode
        
        // Set the initial camera position to the left side of the screen
        initialCameraPosition = CGPoint(x: size.width / 4, y: size.height / 2)
        cameraNode.position = initialCameraPosition
        
        // Initialize the opponent camera position to the right side of the screen
        opponentCameraPosition = CGPoint(x: 3 * size.width / 4, y: size.height / 2)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if let node = atPoint(location) as? SKSpriteNode, node.name == "chicken" || node.name == "duck" {
            
            node.physicsBody = nil
            // Create the orange and add it to the scene at the touch location
            orange = Orange()
            orange?.physicsBody?.isDynamic =  false
            orange?.position = location
            addChild(orange!)
            
            // Store the location of the touch
            touchStart = location
            
            // Reset the shot flag
            isOrangeShot = false
            
            selectedNode = node
            touchStartTime = touch.timestamp
            isNodeReadyToMove = false
            initialNodePosition = node.position
            print("\(node.name!) touched")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        var location = touch.location(in: self)
        
        if token <= 0 { return }
        
        if !isNodeReadyToMove{
            let dx = location.x - touchStart.x
            let dy = location.y - touchStart.y
            let distance = sqrt(dx*dx + dy*dy)
            
            // Check if the distance exceeds the maximum distance
            if distance > maxDragDistance {
                let angle = atan2(dy, dx)
                location.x = touchStart.x + cos(angle) * maxDragDistance
                location.y = touchStart.y + sin(angle) * maxDragDistance
            }
            
            // Update the position of the Orange to the current location
            orange?.position = location
            
            // Show the predicted projectile path with dotted lines
            showProjectilePath(start: touchStart, end: location)
            
            // Draw the firing vector
            let path = UIBezierPath()
            path.move(to: touchStart)
            path.addLine(to: location)
            shapeNode.path = path.cgPath
            shapeNode.isHidden = false
        }
        
        guard let node = selectedNode else { return }
        if token <= 0 { return }
        
        if !node.contains(location) {
            touchStartTime = nil
        }
        
        if isNodeReadyToMove {
            node.position.x = location.x
            orange?.removeFromParent()
            orange = nil
        }
    }
    
    func showProjectilePath(start: CGPoint, end: CGPoint) {
        // Remove any existing dots
        for dot in pathDots {
            dot.removeFromParent()
        }
        pathDots.removeAll()
        
        // Calculate the initial velocity based on the drag distance
        let dx = (start.x - end.x) * 0.5
        let dy = (start.y - end.y) * 0.5
        let initialVelocity = CGVector(dx: dx, dy: dy)
        
        // Simulate the projectile path
        let numberOfPoints = 6  // Number of points for the path
        let timeStep: CGFloat = 0.3 // Time step for the simulation
        
        for i in 0..<numberOfPoints {
            let t = timeStep * CGFloat(i)
            let newPosition = CGPoint(
                x: start.x + initialVelocity.dx * t,
                y: start.y + initialVelocity.dy * t + 0.5 * physicsWorld.gravity.dy * t * t
            )
            
            // Create a dot for the current position
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.position = newPosition
            dot.fillColor = UIColor.white
            dot.strokeColor = UIColor.clear
            addChild(dot)
            
            // Add the dot to the array
            pathDots.append(dot)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Get the location of where the touch ended
        let touch = touches.first!
        let location = touch.location(in: self)
        
        // Get the difference between the start and end point as a vector
        let dx = (touchStart.x - location.x) * 0.4
        let dy = (touchStart.y - location.y) * 0.4
        
        let vector = CGVector(dx: dx, dy: dy)
        
        // Set the Orange dynamic again and apply the vector as an impulse
        orange?.physicsBody?.isDynamic = true
        orange?.physicsBody?.applyImpulse(vector)
        
        // Set the orange shot flag to true
        isOrangeShot = true
        
        // Remove the path from shapeNode
        shapeNode.path = nil
        
        // Add the turn
        turn += 1
        
        //        // Disable shooting
        //        canShoot = false
        
        // Remove any remaining dots
        for dot in pathDots {
            dot.removeFromParent()
        }
        pathDots.removeAll()
        
        guard let node = selectedNode, let initialPosition = initialNodePosition else {return}
        
        
        if cancelIcon.contains(location) {
            node.position = initialPosition
            isNodeReadyToMove = false
            node.alpha = 1.0
            touchStartTime = nil
        }else{
            if node.position != initialPosition && token > 0 {
                //                token -= 1
            }
            node.alpha = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let newPhysicsBody = SKPhysicsBody(rectangleOf: node.size)
            newPhysicsBody.isDynamic = true
            newPhysicsBody.allowsRotation = false
            newPhysicsBody.pinned = false
            newPhysicsBody.affectedByGravity = true
            node.physicsBody = newPhysicsBody
        }
        
        selectedNode = nil
        touchStartTime = nil
        isNodeReadyToMove = false
    }
    
    //    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        if let node = selectedNode {
    //            node.alpha = 1.0
    //        }
    //        selectedNode = nil
    //        touchStartTime = nil
    //        isNodeReadyToMove = false
    //    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update the camera position to follow the orange
        if let orange = orange {
            // Ensure the camera stays within the scene bounds
            let cameraX = clamp(value: orange.position.x, lower: size.width / 4, upper: size.width - size.width / 4)
            cameraNode.position = CGPoint(x: cameraX, y: size.height / 2)
            
            // Ensure the orange stays within the scene bounds
            orange.position.x = clamp(value: orange.position.x, lower: orange.size.width / 2, upper: size.width - orange.size.width / 2)
            orange.position.y = clamp(value: orange.position.y, lower: orange.size.height / 2, upper: size.height - orange.size.height / 2)
            
            // Check if the orange has stopped moving and has been shot
            if isOrangeShot && orange.physicsBody?.velocity == CGVector(dx: 0, dy: 0) {
                if orangeStoppedTime == nil {
                    orangeStoppedTime = currentTime
                } else if currentTime - orangeStoppedTime! > 0.2 {
                    // After 0.2 second, move the camera back and remove the orange
                    moveCameraAndRemoveOrange()
                }
            } else {
                orangeStoppedTime = nil
            }
        }
        
        if let touchStartTime = touchStartTime, let node = selectedNode {
            let touchDuration = currentTime - touchStartTime
            
            if touchDuration >= 3.0 && token > 0 {
                isNodeReadyToMove = true
                node.alpha = 0.5
            }
        }
    }
    
    func moveCameraAndRemoveOrange() {
        // Determine the new camera position based on the turn
        let position: CGPoint = turn % 2 == 0 ? opponentCameraPosition : initialCameraPosition
        let moveAction = SKAction.move(to: position, duration: 0.5)
        //        let zoomInAction = turn % 2 == 0 ? zoomInBottomRight() : zoomInBottomLeft()
        //        let groupAction = SKAction.group([moveAction, zoomInAction])
        cameraNode.run(moveAction) { [weak self] in
            // Remove the orange from the scene
            self?.orange?.removeFromParent()
            self?.orange = nil
            self?.isOrangeShot = false // Reset the flag
            
            // Enable shooting again
            self?.canShoot = true
        }
    }
    
    func zoomInBottomLeft() -> SKAction {
        let scaleAction = SKAction.scale(to: 0.75, duration: 0.5)
        let moveAction = SKAction.move(to: CGPoint(x: cameraNode.position.x - (size.width * 0.25), y: cameraNode.position.y - (size.height * 0.25)), duration: 0.5)
        return SKAction.group([scaleAction, moveAction])
    }
    
    func zoomInBottomRight() -> SKAction {
        let scaleAction = SKAction.scale(to: 0.75, duration: 0.5)
        let moveAction = SKAction.move(to: CGPoint(x: cameraNode.position.x + (size.width * 0.25), y: cameraNode.position.y - (size.height * 0.25)), duration: 0.5)
        return SKAction.group([scaleAction, moveAction])
    }
    
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
    func reduceLife() {
        
//        lifeTroops -= 1
//        if lifeTroops <= 0 {
//            lifeTroops = 0
//        }
//        lifeNodes[lifeTroops].texture = SKTexture(imageNamed: "heart-off")
        
        //===

        if lifeTroops <= 0 {
                lifeTroops = 0
                return
            }

            // Calculate the index based on current lifeTroops, starting from right to left
            let index = lifeTroops - 1
            let currentNode = lifeNodes[index]

            // Check the current texture of the node
            if currentNode.texture?.description.contains("heart-half") == true {
                // If already "heart-half", change it to "heart-off" and decrement lifeTroops
                currentNode.texture = SKTexture(imageNamed: "heart-off")
                lifeTroops -= 1
            } else {
                // If not "heart-half", change it to "heart-half" now
                currentNode.texture = SKTexture(imageNamed: "heart-half")
            }
        
    }
}




extension GameScene: SKPhysicsContactDelegate {
    // Called when the physicsWorld detects two nodes colliding
    func didBegin(_ contact: SKPhysicsContact) {
        
        //
        
//        let nodeA = contact.bodyA.node
//        let nodeB = contact.bodyB.node
//
//        // Check that the bodies collided hard enough
//        if contact.collisionImpulse > 5 {
//            if nodeA?.name == "monster-1" {
//                removeSkull(node: nodeA!)
//            } else if nodeB?.name == "monster-1" {
//                removeSkull(node: nodeB!)
//            }
//        }
        
        //
        
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Orange ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Character: //kena sekali --> heart health decrease (TROOPS)
            if contact.collisionImpulse > 20 {
                reduceLife()
                
                if lifeTroops == 0, let node = other.node { //kena tiga kali --> ilang
                    node.removeFromParent()
                }
            }
        default: break
            
        }
        
        
    }
}
