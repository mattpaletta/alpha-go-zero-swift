//
//  Board.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

class Board {
    
    let size: Int
    var pieces: [[Int]]
    
    init(size: Int) {
        self.size = size
        
        self.pieces = Array(0..<size).map({ (_) -> [Int] in
            return Array(repeating: 0, count: size)
        })
    }
    
    func get_canonical_form(player: Int) -> Board {
        self.pieces = self.pieces * player
        return self
    }
}