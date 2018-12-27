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
    var canonical_board: [[[Int]]] {
        get {
            return self.pieces.map { (row) -> [[Int]] in
                return row.map({ (col) -> [Int] in
                    return [col]
                })
            }
        }
    }
    
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
    
    func execute_move(move: (Int, Int), player: Int) {
        let (x, y) = move
        assert(self.pieces[x][y] == 0)
        self.pieces[x][y] = player
    }
    
    func get_legal_moves() -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        
        // Get all empty locations.
        for y in 0 ..< self.size {
            for x in 0 ..< self.size {
                if self.pieces[x][y] == 0 {
                    moves.append((x, y))
                }
            }
        }
        
        return moves
    }
    
    func has_legal_moves() -> Bool {
        return self.get_legal_moves().count > 0
    }
}
