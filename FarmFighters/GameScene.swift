//
//  GameScene.swift
//  Euphorience
//
//  Created by Anggara Satya Wimala Nelwan on 07/06/24.
//

import SpriteKit
import GameplayKit

enum WeaponType {
    case orange
    case bom
}

class GameScene: SKScene {
    var player1: Player = Player(characters: [])
    var player2: Player = Player(characters: [])
    
    var hasTurnIncremented: Bool = false
    
    var characters = [String: Character]()
    
    var orange: Orange?
    var bom: Bom?
    var touchStart: CGPoint = .zero
    var shapeNode = SKShapeNode()
    var boundary = SKNode()
    var numOfLevels: UInt32 = 6
    var pathDots = [SKShapeNode]() // Array to hold the dot nodes
    let maxDragDistance: CGFloat = 150.0
    var turn: UInt32 = 1
    
    
    var selectedCharacter: Character?
    var token = 1
    var touchStartTime: TimeInterval?
    var isNodeReadyToMove = false {
        didSet{
            cancelIcon.isHidden = !isNodeReadyToMove
        }
    }
    var initialNodePosition: CGPoint?
    var cancelIcon: SKSpriteNode!
    
    var orangeButton: [SKSpriteNode] = []
    var bomButton: [SKSpriteNode] = []
    
    // Current weapon type
    var currentWeapon: WeaponType = .orange
    
    var cameraNode = SKCameraNode()
    var initialCameraPosition: CGPoint = .zero
    var opponentCameraPosition: CGPoint = .zero
    var orangeStoppedTime: TimeInterval?
    var isOrangeShot = false
    var canShoot = true
    
    func setUpCharacter(){
        let characterNames = ["chicken1", "chicken2", "chicken3", "duck1", "duck2", "duck3"]
        for name in characterNames {
            if let node = childNode(withName: name) {
                let character = Character(node: node, scene: self)
                character.physicsBody!.categoryBitMask = PhysicsCategory.Character
                character.physicsBody!.contactTestBitMask = PhysicsCategory.Orange
                
                characters[name] = character
                
                node.removeFromParent()
                addChild(character)
                
                if name.contains("chicken") {
                    player1.characters.append(character)
                } else if name.contains("duck") {
                    player2.characters.append(character)
                }
            }
        }
    }
    
    override func didMove(to view: SKView) {
        shapeNode.lineWidth = 40
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        // Set the contact delegate
        physicsWorld.contactDelegate = self
        
        // Setup the boundaries
//        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(origin: .zero, size: size))
//        boundary.position = .zero
//        addChild(boundary)
        
        setUpCharacter()
        
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
        
        // Create and position the buttons
        createButtons()
    }
    
    func createButtons() {
        // Create first set of buttons
        let orangeTexture = SKTexture(imageNamed: "OrangeButton")
        let orangeButton1 = SKSpriteNode(texture: orangeTexture)
        orangeButton1.position = CGPoint(x: 100, y: 550) // Set an absolute position for the first orange button
        orangeButton1.zPosition = 100 // Ensure it's rendered on top of other nodes
        addChild(orangeButton1) // Add the first orange button to the scene
        
        let bomTexture = SKTexture(imageNamed: "bomButton")
        let bomButton1 = SKSpriteNode(texture: bomTexture)
        bomButton1.position = CGPoint(x: 200, y: 550) // Set an absolute position for the first bom button
        bomButton1.zPosition = 100 // Ensure it's rendered on top of other nodes
        addChild(bomButton1) // Add the first bom button to the scene
        
        // Create second set of buttons
        let orangeTexture2 = SKTexture(imageNamed: "OrangeButton")
        let orangeButton2 = SKSpriteNode(texture: orangeTexture2)
        orangeButton2.position = CGPoint(x: 4300, y: 550) // Set an absolute position for the second orange button
        orangeButton2.zPosition = 100 // Ensure it's rendered on top of other nodes
        addChild(orangeButton2) // Add the second orange button to the scene
        
        let bomTexture2 = SKTexture(imageNamed: "bomButton")
        let bomButton2 = SKSpriteNode(texture: bomTexture2)
        bomButton2.position = CGPoint(x: 4200, y: 550) // Set an absolute position for the second bom button
        bomButton2.zPosition = 100 // Ensure it's rendered on top of other nodes
        addChild(bomButton2) // Add the second bom button to the scene
        
        // Assign the class variables for later reference
        self.orangeButton = [orangeButton1, orangeButton2]
        self.bomButton = [bomButton1, bomButton2]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if let node = atPoint(location) as? SKSpriteNode, let nodeName = node.name, let character = characters[nodeName]{
            
            node.physicsBody = nil
            if currentWeapon == .orange{
                // Create the orange and add it to the scene at the touch location
                orange = Orange()
                orange?.physicsBody?.isDynamic =  false
                orange?.position = location
                addChild(orange!)
            }else if currentWeapon == .bom {
                // Create the bom and add it to the scene at the touch location
                bom = Bom()
                bom?.physicsBody?.isDynamic = false
                bom?.physicsBody?.density = 0.3
                bom?.position = location
                addChild(bom!)
            }
            
            // Store the location of the touch
            touchStart = location
            
            // Reset the shot flag
            isOrangeShot = false
            
            selectedCharacter = character
            initialNodePosition = character.position
            touchStartTime = touch.timestamp
            isNodeReadyToMove = false
            //            initialNodePosition = node.position
            print("\(node.name!) touched")
        }else{
            
            // Check if the touch was on any of the weapon buttons
            for button in orangeButton {
                if button.contains(location) {
                    currentWeapon = .orange
                    break
                }
            }
            
            for button in bomButton {
                if button.contains(location) {
                    currentWeapon = .bom
                    break
                }
            }
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
            switch currentWeapon {
            case .orange:
                orange?.position = location
            case .bom:
                bom?.position = location
            }
            
            // Show the predicted projectile path with dotted lines
            showProjectilePath(start: touchStart, end: location)
            
            // Draw the firing vector
            let path = UIBezierPath()
            path.move(to: touchStart)
            path.addLine(to: location)
            shapeNode.path = path.cgPath
            shapeNode.isHidden = false
        }
        
        guard let character = selectedCharacter else { return }
        if token <= 0 { return }
        
        if !character.contains(location) {
            touchStartTime = nil
        }
        
        if isNodeReadyToMove {
            character.position.x = location.x
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
        
        // Set the weapon dynamic again and apply the vector as an impulse
        switch currentWeapon {
        case .orange:
            orange?.physicsBody?.isDynamic = true
            orange?.physicsBody?.applyImpulse(vector)
            hasTurnIncremented = false // Reset the flag when orange is thrown
        case .bom:
            bom?.physicsBody?.isDynamic = true
            bom?.physicsBody?.applyImpulse(vector)
            hasTurnIncremented = false // Reset the flag when bom is thrown
        }
        
        // Set the orange shot flag to true
        isOrangeShot = true
        
        // Remove the path from shapeNode
        shapeNode.path = nil
        
        
        //        // Disable shooting
        //        canShoot = false
        
        // Remove any remaining dots
        for dot in pathDots {
            dot.removeFromParent()
        }
        pathDots.removeAll()
        
        guard let character = selectedCharacter, let initialPosition = initialNodePosition else {return}
        
        
        if cancelIcon.contains(location) {
            character.position = initialPosition
            isNodeReadyToMove = false
            character.alpha = 1.0
            character.heart.alpha = 1.0
            touchStartTime = nil
        }else{
            if initialNodePosition != character.position && token > 0 {
                //                token -= 1
            }
            character.alpha = 1.0
            character.heart.alpha = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let texture = character.texture {
                DispatchQueue.global(qos: .userInitiated).async {
                    let newPhysicsBody = SKPhysicsBody(texture: texture, size: character.size)
                    newPhysicsBody.isDynamic = false
                    newPhysicsBody.allowsRotation = false
                    newPhysicsBody.pinned = false
                    newPhysicsBody.affectedByGravity = true
                    newPhysicsBody.categoryBitMask = PhysicsCategory.Character
                    newPhysicsBody.contactTestBitMask = PhysicsCategory.Orange
                    
                    DispatchQueue.main.async {
                        character.physicsBody = newPhysicsBody
                    }
                }
            }
        }
        
        selectedCharacter = nil
        touchStartTime = nil
        isNodeReadyToMove = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isOrangeShot {
            if let weapon = orange != nil ? orange : bom {
                // Check if the orange velocity is near zero
                if abs(weapon.physicsBody!.velocity.dx) > 0 && abs(weapon.physicsBody!.velocity.dy) > 0 {
                    // Check if the orange is on the ground or has come to a stop (you may need to adjust this condition based on your game)
                    // Remove the orange and move the camera
                    if !hasTurnIncremented {
                        turn += 1
                        print("Turn increased to \(turn)")
                        hasTurnIncremented = true // Set the flag to true to prevent further increments
                    }
                }
               
                if abs(weapon.physicsBody!.velocity.dx) < 200 && abs(weapon.physicsBody!.velocity.dy) < 200 {
                    // Check if the orange is on the ground or has come to a stop (you may need to adjust this condition based on your game)
                    // Remove the orange and move the camera
                    moveCameraAndRemoveOrange()
                }
            }
        }

        // Update the camera position to follow the orange
        if let weapon = orange != nil ? orange : bom {
            // Ensure the camera stays within the scene bounds
            let cameraX = clamp(value: weapon.position.x, lower: size.width / 4, upper: size.width - size.width / 4)
            cameraNode.position = CGPoint(x: cameraX, y: size.height / 2)

            // Ensure the orange stays within the scene bounds
            weapon.position.x = clamp(value: weapon.position.x, lower: weapon.size.width / 2, upper: size.width - weapon.size.width / 2)
            weapon.position.y = clamp(value: weapon.position.y, lower: weapon.size.height / 2, upper: size.height - weapon.size.height / 2)

            // Check if the orange has stopped moving and has been shot
            if isOrangeShot && weapon.physicsBody?.velocity == CGVector(dx: 0, dy: 0) {
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

        if let touchStartTime = touchStartTime, let character = selectedCharacter {
            let touchDuration = currentTime - touchStartTime

            if touchDuration >= 3.0 && token > 0 {
                isNodeReadyToMove = true
                character.alpha = 0.5
                character.heart.alpha = 0.5
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
            if self?.currentWeapon == .orange{
                self?.orange?.removeFromParent()
                self?.orange = nil
                self?.isOrangeShot = false // Reset the flag
            }
            else if self?.currentWeapon == .bom{
                self?.bom?.removeFromParent()
                self?.bom = nil
                self?.isOrangeShot = false // Reset the flag
            }
            
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
    
    func resetGame() {
        // Reset player characters and any other necessary game state
        player1.characters = []
        player2.characters = []
    }

    
    func checkEndGame() {
        if player1.characters.isEmpty {
            player2.winningRound += 1
            
            // ini reset game masih ga jalan
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.resetGame()
            }
        } else if player1.characters.isEmpty {
            player1.winningRound += 1
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.resetGame()
            }
        }
    }

    
    func reduceLife(character: Character) {
        character.health -= 0.5
        
        if character.health <= 0 {
            characters.removeValue(forKey: character.name ?? "")
            character.removeFromParent()
            
            if let index = player1.characters.firstIndex(where: { $0.name == character.name }) {
                player1.characters.remove(at: index)
            } else if let index = player2.characters.firstIndex(where: { $0.name == character.name }) {
                player2.characters.remove(at: index)
            }
            
            checkEndGame() // Check if this was the last character for any player
        }
    }
}




extension GameScene: SKPhysicsContactDelegate {
    // Called when the physicsWorld detects two nodes colliding
    func didBegin(_ contact: SKPhysicsContact) {
        
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Orange ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Character:
            if contact.collisionImpulse > 20 {
                if let character = other.node as? Character {
                    reduceLife(character: character)
                }
            }
        default:
            break
        }
        
        
    }
}
