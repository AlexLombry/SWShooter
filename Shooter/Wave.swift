//
//  Wave.swift
//  Shooter
//
//  Created by Alex Lombry on 15/12/2019.
//  Copyright © 2019 Alex Lombry. All rights reserved.
//

import SpriteKit

struct Wave: Codable {
    struct WaveEnemy: Codable {
        var position: Int
        var xOffset: CGFloat
        var moveStraight: Bool
    }
    
    var name: String
    var enemies: [WaveEnemy]
}
