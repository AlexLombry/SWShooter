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

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        // Create backgroup particules look like space
        if let particles = SKEmitterNode(fileNamed: "Starfield") {
            particles.position = CGPoint(x: 1068, y: 0)
            particles.advanceSimulationTime(60)
            particles.zPosition = -1
            addChild(particles)
        }
        
        // Make the player, start in middle left
        player.name = "Player One"
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
}
