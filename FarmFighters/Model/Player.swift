//
//  Player.swift
//  FarmFighters
//
//  Created by Anggara Satya Wimala Nelwan on 19/06/24.
//

import Foundation


class Player{
    var movementToken: Int = 2
    var characters: [Character]
    var numberOfBombs: Int = 1
    var winningRound: Int = 0
    
    init(characters: [Character]) {
        self.characters = characters
    }
}
