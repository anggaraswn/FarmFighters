//
//  GameScene.swift
//  Euphorience
//
//  Created by Anggara Satya Wimala Nelwan on 07/06/24.
//

import SpriteKit
import GameplayKit

enum WeaponType {
    case basic
    case bom
}

enum PlayerTurn {
    case player1
    case player2
}

class GameScene: SKScene {
    static var round: Int = 1
    
    static var player1: Player = Player(characters: [], turn: .player1)
    static var player2: Player = Player(characters: [], turn: .player2)
    
    var characters = [String: Character]()
    var obstacles = [String: Obstacle]()
    
    var weapon: Weapon?
    var touchStart: CGPoint = .zero
    var touchStartTime: TimeInterval?
    var shapeNode = SKShapeNode()
    var pathDots = [SKShapeNode]() // Array to hold the dot nodes
    let maxDragDistance: CGFloat = 150.0
    var playerTurn: PlayerTurn = .player1
    
    var selectedCharacter: Character?
    var isNodeReadyToMove = false
    var initialNodePosition: CGPoint?
    var cancelIcon: SKSpriteNode!
    
    var positionButton: [SKSpriteNode] = []
    var bomButton: [SKSpriteNode] = []
    
    // Current weapon type
    var currentWeapon: WeaponType = .basic
    
    var cameraNode = SKCameraNode()
    var initialCameraPosition: CGPoint = .zero
    var opponentCameraPosition: CGPoint = .zero
    var orangeStoppedTime: TimeInterval?
    var isWeaponShot = false
    var isGameOver = false
    var isBombShot = false
    var countdownLabel: SKSpriteNode = SKSpriteNode()
    
    
    //sound + music
    let audioManager = SKTAudio.sharedInstance()
    
    var aiming = SKAction.playSoundFileNamed("aiming.mp3")
    var shoot = SKAction.playSoundFileNamed("shoot.mp3")
    
    var hitStone = SKAction.playSoundFileNamed("stone-hit.mp3")
    var hitBomb = SKAction.playSoundFileNamed("bomb-hit-and-explosion.mp3")
    var bell = SKAction.playSoundFileNamed("boxing-bell")
    
    let doneTexture = SKTexture(imageNamed: "Done")
    let changePositionDeadTexture = SKTexture(imageNamed: "ChangePositionDead")

    var isRepositioning = false // Flag to track reposition process
    
    static func loadRound(round: Int) -> GameScene? {
        return GameScene(fileNamed: "Round-\(GameScene.round)")
    }
    
    override func didMove(to view: SKView) {
        GameScene.player1.winningRound = 1
        print("Round = \(GameScene.round)")
        shapeNode.lineWidth = 40
        shapeNode.lineCap = .round
        shapeNode.strokeColor = UIColor(white: 1, alpha: 0.3)
        addChild(shapeNode)
        
        // Set the contact delegate
        physicsWorld.contactDelegate = self
        
        setUpObstacle()
        setUpCharacter()
        
        cancelIcon = SKSpriteNode(imageNamed: "cancelIcon")
        cancelIcon.name = "cancelIcon"
        cancelIcon.isHidden = true // Hide the cancel icon initially
        addChild(cancelIcon)
        
        // Add the camera to the scene
        addChild(cameraNode)
        camera = cameraNode
        
        // Calculate camera positions based on the scene size
        let cameraPositions = calculateCameraPositions(sceneWidth: size.width, screenSize: view.bounds.size)
        initialCameraPosition = cameraPositions.initialCameraPosition
        opponentCameraPosition = cameraPositions.opponentCameraPosition

        // Set the initial camera position
        cameraNode.position = initialCameraPosition
        
        // Create and position the buttons
        createButtons()
        
        
        let roundText = displayImage(imageNamed: "round-r\(GameScene.round)", anchorPoint: CGPoint(x: 0.5, y: 0.5))
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            roundText.removeFromParent()
        }
        
        //background music
        
        switch GameScene.round {
        case 1:
            audioManager.playBGMusic("musicLevel1.mp3", volume: 0.2)
        case 2:
            audioManager.playBGMusic("musicLevel2.mp3", volume: 0.2)
        case 3:
            audioManager.playBGMusic("musicLevel3.mp3", volume: 0.2)
        default:
            break
        }
        
        //bell sound effect
        run(bell)
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        
        if let node = atPoint(location) as? SKSpriteNode, let nodeName = node.name, let character = characters[nodeName], !isWeaponShot{
            
            selectedCharacter = character
            initialNodePosition = character.position
            touchStartTime = touch.timestamp
            
            guard !isNodeReadyToMove else {
                if let texture = selectedCharacter?.node.texture {
                    let newPhysicsBody = SKPhysicsBody(texture: texture, size: (selectedCharacter?.node.size)!)
                    newPhysicsBody.isDynamic = true
                    newPhysicsBody.allowsRotation = false
                    newPhysicsBody.pinned = false
                    newPhysicsBody.affectedByGravity = true
                    newPhysicsBody.categoryBitMask = PhysicsCategory.Character
                    newPhysicsBody.contactTestBitMask = PhysicsCategory.Orange
                    selectedCharacter?.node.physicsBody = newPhysicsBody
                }
                return
            }
            
            node.physicsBody = nil
            
            
            print("Turn \(playerTurn == .player1 ? "player1" : "player2")")
            weapon = Weapon(type: currentWeapon, playerTurn: playerTurn)
            weapon?.zPosition = 20
            weapon?.physicsBody?.isDynamic = false
            weapon?.position = location
            addChild(weapon!)
            
            // Store the location of the touch
            touchStart = location
            
            // Reset the shot flag
            isWeaponShot = false
            
            
           
//            isNodeReadyToMove = false
            startCountdown()
            run(aiming)
            
        } else {
            // Check if the touch was on any of the weapon buttons
            
            
            for button in positionButton {
                if button.contains(location) {

                    // Check the button's state and update accordingly
                    if button.userData == nil {
                        button.userData = ["state": "initial"]
                    }
                    
                    if button.userData?["state"] as? String == "initial" {
                 
                            let informationRepositioning = displayImage(imageNamed: "informationText", anchorPoint: CGPoint(x: 0.5, y: 0.5))
                            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                                informationRepositioning.removeFromParent()
                            }
                            
                            button.texture = SKTexture(imageNamed: "Done")
                            button.userData = ["state": "done"]
                            isNodeReadyToMove = true
                        
                    } else if button.userData?["state"] as? String == "done" {
                        button.texture = SKTexture(imageNamed: "ChangePositionDead")
                        button.userData = ["state": "changePositionDead"]
                        isNodeReadyToMove = false
                    } else if button.userData?["state"] as? String == "changePositionDead" {
                        showAlert(title: "Reposition Used", message: "You have already used the reposition this round.")
                    }
                    
                    break
                }
            }


            
            for button in bomButton {
                
                if button.contains(location) {
                    if button.userData == nil {
                        button.userData = ["state": "initial"]
                    }
                    
                    if button.userData?["state"] as? String == "initial" {
                        button.texture = SKTexture(imageNamed: "BombAttackDead")
                        button.userData = ["state": "done"]
                        currentWeapon = .bom
                    }
                    
                    else {
                        showAlert(title: "Bom Used", message: "You have already used the bom this round.")
                    }
                    break
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        var location = touch.location(in: self)
        
        
        if !isNodeReadyToMove && !isWeaponShot{
            let dx = location.x - touchStart.x
            let dy = location.y - touchStart.y
            let distance = sqrt(dx*dx + dy*dy)
            
            // Check if the distance exceeds the maximum distance
            if distance > maxDragDistance {
                let angle = atan2(dy, dx)
                location.x = touchStart.x + cos(angle) * maxDragDistance
                location.y = touchStart.y + sin(angle) * maxDragDistance
            }
            
            weapon?.position = location
            
            // Show the predicted projectile path with dotted lines
            showProjectilePath(start: touchStart, end: location)
            
            // Draw the firing vector
            let path = UIBezierPath()
            path.move(to: touchStart)
            path.addLine(to: location)
            shapeNode.path = path.cgPath
            shapeNode.zPosition = 10
            shapeNode.isHidden = false
            
            if(currentWeapon == .bom){
                isBombShot = true
                resetWeaponToOrange()
            }
        }
        
        guard let character = selectedCharacter else { return }
        
        if !character.node.contains(location) {
            touchStartTime = nil
        }
        
        if getCurrentPlayer().movementToken <= 0 { return }
        
        if isNodeReadyToMove {
            character.position.x = location.x
            character.position.y = location.y
            adjustCharacterPosition(character: character)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Get the location of where the touch ended
        let touch = touches.first!
        let location = touch.location(in: self)
        
        countdownLabel.removeAllActions()
        countdownLabel.removeFromParent()
        
        guard let character = selectedCharacter else { return }
        
        if touchStart != .zero{
            shootWeapon()
        }
        
        guard let initialPosition = initialNodePosition else {return}
        
        
        if cancelIcon.contains(location) {
            character.position = initialPosition
        }else{
            if initialNodePosition != character.position && getCurrentPlayer().movementToken > 0 {
//                getCurrentPlayer().movementToken -= 1
            }
        }
        
        character.node.alpha = 1.0
        character.heart.alpha = 1.0
        selectedCharacter = nil
        touchStartTime = nil
//        isNodeReadyToMove = false
    }
    
    func resetWeaponToOrange() {
        if isBombShot {
            // Code to set the weapon back to orange
            currentWeapon = .basic // Assuming `orangeWeapon` is defined elsewhere in your code
            isBombShot = false
            isWeaponShot = false // Reset the orange shot status
        }
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if let viewController = self.view?.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update the camera position to follow the orange
        if isWeaponShot, let weapon = weapon {
            guard !isGameOver else { return }
            // Check if the weapon is out of bounds
            if weapon.position.x < 0 || weapon.position.x > size.width || weapon.position.y < 0 || weapon.position.y > size.height {
                print("Out of scene")
                removeWeapon()
                moveCameraAndRemoveOrange()
                return
            }
            
            // Ensure the camera stays within the scene bounds
            let lowerBound = view!.bounds.size.width
            let upperBound = size.width - view!.bounds.size.width
            let cameraX = clamp(value: weapon.position.x, lower: lowerBound, upper: upperBound)
            cameraNode.position = CGPoint(x: cameraX, y: size.height / 2)

            
//            // Ensure the orange stays within the scene bounds
//            weapon.position.x = clamp(value: weapon.position.x, lower: weapon.size.width / 2, upper: size.width - weapon.size.width / 2)
//            weapon.position.y = clamp(value: weapon.position.y, lower: weapon.size.height / 2, upper: size.height - weapon.size.height / 2)
            
            // Check if the orange has stopped moving and has been shot
            if abs(weapon.physicsBody!.velocity.dx) < 200 && abs(weapon.physicsBody!.velocity.dy) < 200 {
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
        for character in characters.values {
            character.updateHeartPosition()
        }
    }
    
    func removeWeapon(){
        weapon?.removeFromParent()
        weapon = nil
        isWeaponShot = false
    }
    
    func moveCameraAndRemoveOrange() {
        // Determine the new camera position based on the turn
        let position: CGPoint = playerTurn == .player2 ? opponentCameraPosition : initialCameraPosition
        let moveAction = SKAction.move(to: position, duration: 0.5)
        //        let zoomInAction = turn % 2 == 0 ? zoomInBottomRight() : zoomInBottomLeft()
        //        let groupAction = SKAction.group([moveAction, zoomInAction])
        cameraNode.run(moveAction) { [weak self] in
            
            // Remove the orange from the scene
            self?.weapon?.removeFromParent()
            self?.weapon = nil
            self?.isWeaponShot = false
        }
    }
    
    func calculateCameraPositions(sceneWidth: CGFloat, screenSize: CGSize) -> (initialCameraPosition: CGPoint, opponentCameraPosition: CGPoint) {
        // Calculate the leftmost camera position
        let initialCameraPosition = CGPoint(x: screenSize.width, y: size.height / 2)
        
        // Calculate the rightmost camera position
        let opponentCameraPosition = CGPoint(x: sceneWidth - screenSize.width, y: size.height / 2)
        
        return (initialCameraPosition, opponentCameraPosition)
    }

    
    func clamp(value: CGFloat, lower: CGFloat, upper: CGFloat) -> CGFloat {
        return min(max(value, lower), upper)
    }
    
    func resetGame() {
        // Reset player characters and any other necessary game state
        GameScene.player1.characters = []
        GameScene.player2.characters = []
    }
    
    func checkEndRound() {
        print("Check Round dipanggil ga")
        if GameScene.player1.characters.isEmpty || GameScene.player2.characters.isEmpty {
            print("Apakah empty player1: \(GameScene.player1.characters.count)")
            print("Apakah empty player2: \(GameScene.player2.characters.count)")
            isGameOver = true
            if GameScene.player1.characters.isEmpty{
                GameScene.player2.winningRound += 1
                _ = displayImage(imageNamed: "ducks-win", anchorPoint: CGPoint(x: 0.5, y: 0.5))
            }else{
                GameScene.player1.winningRound += 1
                _ = displayImage(imageNamed: "chickens-win", anchorPoint: CGPoint(x: 0.5, y: 0.5))
            }
            resetGame()
            GameScene.round += 1
            if checkVictory(){
                print("Game Over")
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                if let scene = GameScene.loadRound(round: GameScene.round){
                    scene.scaleMode = .aspectFill
                    if let view = self.view {
                        view.presentScene(scene)
                    }
                }
            }
        }
    }
    
    func chickenVictory(){
        let chicken = SKSpriteNode(imageNamed: "chickens-victory")
        chicken.name = "chicken"
        chicken.zPosition = 101.0
        chicken.position = cameraNode.position
        
        addChild(chicken)
    }
    
    func duckVictory(){
        let duck = SKSpriteNode(imageNamed: "ducks-victory")
        duck.name = "duck"
        duck.zPosition = 101.0
        duck.position = cameraNode.position
        
        addChild(duck)
    }
    
    
    
    func checkVictory() -> Bool{
        if GameScene.player1.winningRound == 2 || GameScene.player2.winningRound == 2{
            isGameOver = true
//            var node: SKSpriteNode
            if GameScene.player1.winningRound == 2{
//                node = displayImage(imageNamed: "chickens-victory", anchorPoint: CGPoint(x: 0.5, y: 0.5))
                chickenVictory()
            }else{
//                node = displayImage(imageNamed: "ducks-victory", anchorPoint: CGPoint(x: 0.5, y: 0.5))
                duckVictory()
            }
            
            let winningRoundLabel = SKLabelNode(text: "\(GameScene.player1.winningRound):\(GameScene.player2.winningRound)")
            winningRoundLabel.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y - 400)
            winningRoundLabel.fontSize = 400
            winningRoundLabel.fontName = "SFProDisplay-Black"
            winningRoundLabel.fontColor = .white

            winningRoundLabel.zPosition = 150
            
            addChild(winningRoundLabel)
            
//            node.zPosition = 101
            return true
        }
        
        return false
    }
    
    func displayImage(imageNamed: String, anchorPoint: CGPoint) -> SKSpriteNode{
        let texture = SKTexture(imageNamed: imageNamed)
        let node = SKSpriteNode(texture: texture)
        node.anchorPoint = anchorPoint
        node.position = cameraNode.position
        node.zPosition = 100
        
        addChild(node)
        return node
    }
    
    func reduceLife(character: Character) {
        character.health -= weapon!.damage
        
        if character.health <= 0 {
            characters.removeValue(forKey: character.node.name ?? "")
            character.node.removeFromParent()
            
            if let index = GameScene.player1.characters.firstIndex(where: { $0.node.name == character.node.name }) {
                GameScene.player1.characters.remove(at: index)
            } else if let index = GameScene.player2.characters.firstIndex(where: { $0.node.name == character.node.name }) {
                GameScene.player2.characters.remove(at: index)
            }
            
            checkEndRound() // Check if this was the last character for any player
        }
    }
    
    func getCurrentPlayer() -> Player{
        return playerTurn == GameScene.player1.turn ? GameScene.player1 : GameScene.player2
    }
    
    func setUpCharacter(){
        let characterNames = ["chicken1", "chicken2", "chicken3", "duck1", "duck2", "duck3"]
        for name in characterNames {
            if let node = childNode(withName: name) as? SKSpriteNode{
                let character = Character(node: node, scene: self)
                character.node.physicsBody!.categoryBitMask = PhysicsCategory.Character
                character.node.physicsBody!.contactTestBitMask = PhysicsCategory.Orange
                character.node.zPosition = 1
                
                characters[name] = character
                
                if name.contains("chicken") {
                    GameScene.player1.characters.append(character)
                } else if name.contains("duck") {
                    GameScene.player2.characters.append(character)
                }
            }
        }
    }
    
    func setUpObstacle(){
        let obsNames = ["obstacle1", "obstacle2", "obstacle3", "obstacle4"]
        for name in obsNames{
            if let node = childNode(withName: name) as? SKSpriteNode{ //assign as SKSpriteNode
                
                
                let obstacle = Obstacle(node: node) // new instance of the Obstacle class
                obstacle.node.physicsBody!.categoryBitMask = PhysicsCategory.Obstacle
                obstacle.node.physicsBody!.contactTestBitMask = PhysicsCategory.Orange
                obstacle.node.physicsBody!.collisionBitMask = PhysicsCategory.Orange
                obstacle.node.zPosition = 1
                
                obstacles[name] = obstacle
            }
        }
    }
    
    func createButtons() {
            let screenWidth = self.size.width

            // Set positions for buttons on the left side of the scene
            let positionTexture1 = SKTexture(imageNamed: "ChangePosition")
            let positionButton1 = SKSpriteNode(texture: positionTexture1)
            positionButton1.position = CGPoint(x: screenWidth * 0.05, y: 130)
            positionButton1.zPosition = 100
            positionButton1.setScale(0.09)
            addChild(positionButton1)

            let bomTexture1 = SKTexture(imageNamed: "BombAttack")
            let bomButton1 = SKSpriteNode(texture: bomTexture1)
            bomButton1.position = CGPoint(x: screenWidth * 0.1, y: 130)
            bomButton1.zPosition = 100
            bomButton1.setScale(0.09)
            addChild(bomButton1)

            // Set positions for buttons on the right side of the scene
            let positionTexture2 = SKTexture(imageNamed: "ChangePosition")
            let positionButton2 = SKSpriteNode(texture: positionTexture2)
            positionButton2.position = CGPoint(x: screenWidth * 0.95, y: 130)
            positionButton2.zPosition = 100
            positionButton2.setScale(0.09)
            addChild(positionButton2)

            let bomTexture2 = SKTexture(imageNamed: "BombAttack")
            let bomButton2 = SKSpriteNode(texture: bomTexture2)
            bomButton2.position = CGPoint(x: screenWidth * 0.9, y: 130)
            bomButton2.zPosition = 100
            bomButton2.setScale(0.09)
            addChild(bomButton2)

            // Assign the class variables for later reference
            self.positionButton = [positionButton1, positionButton2]
            self.bomButton = [bomButton1, bomButton2]
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
            dot.zPosition = 10
            addChild(dot)
            
            // Add the dot to the array
            pathDots.append(dot)
        }
    }
    
    func adjustCharacterPosition(character: Character) {
        let rayStart = CGPoint(x: character.position.x, y: character.position.y + 100)
        let rayEnd = CGPoint(x: character.position.x, y: character.position.y - 1000)
        
        var groundHeight: CGFloat = character.position.y // Default to current position if no ground found
        
        physicsWorld.enumerateBodies(alongRayStart: rayStart, end: rayEnd) { (body, point, normal, fraction) in
            if body.categoryBitMask == PhysicsCategory.Ground {
                groundHeight = point.y
            }
        }
        
        character.position.y = groundHeight + (character.node.size.height / 2)
    }
    
    func shootWeapon() {
        // Get the current position of the weapon
        guard let weapon = weapon, let character = selectedCharacter else { return }
        let currentLocation = weapon.position
        
        // Get the difference between the start and current point as a vector
        let dx = (touchStart.x - currentLocation.x) * 1
        let dy = (touchStart.y - currentLocation.y) * 1
        
        let vector = CGVector(dx: dx, dy: dy)
        
        // Set the weapon dynamic again and apply the vector as an impulse
        weapon.physicsBody?.isDynamic = true
        weapon.physicsBody?.applyImpulse(vector)
        
        // Set the orange shot flag to true
        isWeaponShot = true
        
        // Remove the path from shapeNode
        shapeNode.path = nil
        
        // Remove any remaining dots
        for dot in pathDots {
            dot.removeFromParent()
        }
        pathDots.removeAll()
        touchStart = .zero
        run(shoot)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let texture = character.node.texture {
                DispatchQueue.global(qos: .userInitiated).async {
                    let newPhysicsBody = SKPhysicsBody(texture: texture, size: character.node.size)
                    newPhysicsBody.isDynamic = true
                    newPhysicsBody.allowsRotation = false
                    newPhysicsBody.pinned = false
                    newPhysicsBody.affectedByGravity = true
                    newPhysicsBody.categoryBitMask = PhysicsCategory.Character
                    newPhysicsBody.contactTestBitMask = PhysicsCategory.Orange
                    
                    DispatchQueue.main.async {
                        character.node.physicsBody = newPhysicsBody
                    }
                }
            }
        }
        
        // Invalidate the dragging timer
        //        draggingTimer?.invalidate()
        //        draggingTimer = nil
        //        draggingStartTime = nil
        
        // Switch player turns
        playerTurn = playerTurn == .player1 ? .player2 : .player1
    }
    
    func startCountdown() {
        var countdownValue = 5
        let texture = SKTexture(imageNamed: "\(countdownValue)")
        countdownLabel = SKSpriteNode(texture: texture)
        countdownLabel.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        countdownLabel.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + 500)
        countdownLabel.zPosition = 100
        countdownLabel.setScale(0.6)
        addChild(countdownLabel)
        
        let countdownAction = SKAction.repeat(SKAction.sequence([
            SKAction.run { [weak self] in
                self?.countdownLabel.texture = SKTexture(imageNamed: "\(countdownValue)")
                countdownValue -= 1
            },
            SKAction.wait(forDuration: 1.0)
        ]), count: 5)
        
        let endCountdownAction = SKAction.run { [weak self] in
            self?.countdownLabel.removeFromParent()
            self?.shootWeapon()
        }
        
        countdownLabel.run(SKAction.sequence([countdownAction, endCountdownAction]))
    }
    
}




extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let weapon = weapon else {return}
        let other = contact.bodyA.categoryBitMask == PhysicsCategory.Orange ? contact.bodyB : contact.bodyA
        
        switch other.categoryBitMask {
        case PhysicsCategory.Character:
            if contact.collisionImpulse > 50 && !isNodeReadyToMove{
                if weapon.type == .basic{
                    run(hitStone)
                }else{
                    run(hitBomb)
                }
                
                if let characterNode = other.node as? SKSpriteNode, let character = characters[characterNode.name ?? ""] {
                    let characterPlayer: Player
                    
                    if GameScene.player1.characters.contains(where: { $0 === character }) {
                        characterPlayer = GameScene.player1
                    } else if GameScene.player2.characters.contains(where: { $0 === character }) {
                        characterPlayer = GameScene.player2
                    } else {
                        return
                    }
                    
                    if weapon.playerTurn != characterPlayer.turn {
                        //                        print("Weapon owned by \(weapon?.playerTurn == .player1 ? "player1" : "player2")")
                        //                        print("Damaged")
                        reduceLife(character: character)
                    }
                }
            }
            
            // obstacle
        case PhysicsCategory.Obstacle:
            if contact.collisionImpulse > 50{
                if let obstacleNode = other.node as? SKSpriteNode, let obstacle = obstacles[obstacleNode.name ?? ""] {
                    if weapon.type == .bom {
                        obstacle.node.removeFromParent()
                        obstacles.removeValue(forKey: obstacleNode.name ?? "")
                        run(hitBomb)
                    }else{
                        run(hitStone)
                    }
                }
            }
            
        default:
            break
        }
    }
}
