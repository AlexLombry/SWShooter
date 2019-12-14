//
//  EnemyFile.swift
//  Shooter
//
//  Created by Alex Lombry on 15/12/2019.
//  Copyright © 2019 Alex Lombry. All rights reserved.
//

import SpriteKit

struct EnemyType: Codable {
    var name: String
    var shields: Int
    var speed: CGFloat
    var powerUpChance: Int
}
