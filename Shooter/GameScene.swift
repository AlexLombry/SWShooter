//
//  GameScene.swift
//  Shooter
//
//  Created by Alex Lombry on 14/12/2019.
//  Copyright © 2019 Alex Lombry. All rights reserved.
//

import SpriteKit

enum CollisionType: UInt32 {
    case player = 1
    case playerWeapon = 2
    case enemy = 4
    case enemyWeapon = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    let waves = Bundle.main.decode([Wave].self, from: "waves.json")
    let enemyTypes = Bundle.main.decode([EnemyType].self, from: "enemy-types.json")
    
    var isPlayerAlive = true
    var levelNumber = 0
    var waveNumber = 0
    var playerShields = 10
    
    let positions = Array(stride(from: -320, through: 320, by: 80))
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        // Create backgroup particules look like space
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1068, y: 0)
            particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        // Make the player, start in middle left
        player.name = "player"
        player.position.x = frame.minX + 75
        player.zPosition = 1
        addChild(player)
        
        // Physics for player
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.texture!.size())
        
        // Deactivate gravity
        player.physicsBody?.isDynamic = false
        
        // What kind this is
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        
        // Collision with enemy AND enemy weapon (bitwize operator)
        player.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        
        // What when collide (bounce around)
        player.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
    
    
    }
    
    override func update(_ currentTime: TimeInterval) {
        for child in children where child.frame.maxX < 0 && !frame.intersects(child.frame) {
            child.removeFromParent()
        }
        
        let activeEnemies = children.compactMap { $0 as? EnemyNode }
        
        if activeEnemies.isEmpty {
            createWave()
        }
        
        for enemy in activeEnemies {
            guard frame.intersects(enemy.frame) else { continue }
            if enemy.lastFireTime + 1 < currentTime {
                enemy.lastFireTime = currentTime
                // random fire
                if Int.random(in: 0...3) == 0 {
                    enemy.fire()
                }
            }
        }
    }
    
    /// Create wave of enemies
    func createWave() {
        // is player alive, game over
        guard isPlayerAlive else { return }
        
        if waveNumber == waves.count {
            levelNumber += 1
            waveNumber = 0
        }
        
        let currentWave = waves[waveNumber]
        waveNumber += 1
        
        let maximumEnemyType = min(enemyTypes.count, levelNumber + 1)
        let enemyType = Int.random(in: 0..<maximumEnemyType)
        
        let enemyOffsetX: CGFloat = 100
        let enemyStartX = 600
        
        // if there are not enemies in our wave, make a random one
        if currentWave.enemies.isEmpty {
            for (index, position) in positions.shuffled().enumerated() {
                let enemy = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: position), xOffset: enemyOffsetX * CGFloat(index * 3), moveStraight: true)
                
                addChild(enemy)
            }
        } else {
            for enemy in currentWave.enemies {
                let node = EnemyNode(type: enemyTypes[enemyType], startPosition: CGPoint(x: enemyStartX, y: positions[enemy.position]), xOffset: enemyOffsetX * enemy.xOffset   , moveStraight: enemy.moveStraight)
                
                addChild(node)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPlayerAlive else { return }
        
        let shot = SKSpriteNode(imageNamed: "playerWeapon")
        shot.name = "playerWeapon"
        shot.position = player.position
        shot.physicsBody = SKPhysicsBody(rectangleOf: shot.size)
        
        shot.physicsBody?.categoryBitMask = CollisionType.playerWeapon.rawValue
        shot.physicsBody?.collisionBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        shot.physicsBody?.contactTestBitMask = CollisionType.enemy.rawValue | CollisionType.enemyWeapon.rawValue
        
        addChild(shot)
        
        let movement = SKAction.move(to: CGPoint(x: 1900, y: shot.position.y), duration: 5)
        let sequence = SKAction.sequence([movement, .removeFromParent()])
        shot.run(sequence)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // nodeB always the player
        let sortedNodes = [nodeA, nodeB].sorted { $0.name ?? "" < $1.name ?? "" }
        let firstNode = sortedNodes[0]
        let secondNode = sortedNodes[1]
        
        if secondNode.name == "player" {
            guard isPlayerAlive else { return }
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = firstNode.position
                addChild(explosion)
            }
            
            playerShields -= 1
            
            if playerShields == 0 {
                gameOver()
                secondNode.removeFromParent()
            }
            
            firstNode.removeFromParent()
        } else if let enemy = firstNode as? EnemyNode {
            enemy.shields -= 1
            
            if enemy.shields == 0 {
                if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                    explosion.position = enemy.position
                    addChild(explosion)
                }
                enemy.removeFromParent()
            }
            
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = enemy.position
                addChild(explosion)
            }
            
            secondNode.removeFromParent()
            
        } else {
            if let explosion = SKEmitterNode(fileNamed: "Explosion") {
                explosion.position = secondNode.position
                addChild(explosion)
            }
            
            firstNode.removeFromParent()
            secondNode.removeFromParent()
        }
    }
    
    func gameOver() {
        isPlayerAlive = false
        
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        let gameOver = SKSpriteNode(imageNamed: "gameOver")
        addChild(gameOver)
    }
}
