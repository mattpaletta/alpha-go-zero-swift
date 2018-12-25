//
//  Game.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation
import Python

class Game {
    
    let size: Int
    let n_in_row: Int
    
    
    var action_size: Int {
        get {
            return self.size * self.size + 1
        }
    }
    
    init(size: Int, history: Int) {
        self.size = size
        self.n_in_row = history
    }
    
    convenience init() {
        self.init(size: 15)
    }
    
    convenience init(size: Int) {
        self.init(size: size, history: 5)
    }
    
    func get_init_board() -> Board {
        let board = Board(size: self.size)
        return board
    }
    
    func as_string(board: Board) -> String {
        return ""
    }
    
    func get_canonical_form(board: Board, player: Int) -> Board {
        return board.get_canonical_form(player: player)
    }
    
    func get_symmetries(board: Board, pi: [Double]) -> [(board: [[Int]], pi: [Double])] {
        assert(pi.count == (self.size ^ 2) + 1)
        let pi_board = Array<Double>.to_square(pi)

        var l: [(board: [[Int]], pi: [Double])] = []
        for i in 1 ..< 5 {
            for j in [true, false] {
                var newB = rotate(board.pieces, i)
                var newPi = rotate(pi_board, i)
                
                if j {
                    newB = fliplr(newB)
                    newPi = fliplr(newPi)
                }
                
                l += [(newB, flatten(newPi) + pi.last!)]
            }
        }
        
        return l
    }
    
    func get_next_state(board: Board, player: Int, action: Int) -> (Board, Int) {
        if action == self.size * self.size {
            return (board, -player)
        }
        let b = Board(size: self.size)
        b.pieces = board.pieces
        let move = (Int(action / self.size), action % self.size)
        b.execute_move(move: move, player: player)
        return (b, -player)
    }
    
    func get_game_ended(board: Board, player: Int) -> Double {
        let b = Board(size: self.size)
        b.pieces = board.pieces
        let n = self.n_in_row
        
        for w in 0 ..< self.size {
            for h in 0 ..< self.size {
                let contains_w = (0 ..< (self.size - n + 1)).contains(w)
                let contains_h = (0 ..< (self.size - n + 1)).contains(h)
                
                let w_range = Set(Array(w ..< w + n).map({ (i) -> Int in
                    return board.pieces[i][h]
                })).count == 1
                
                let h_range = Set(Array(h ..< h + n).map({ (j) -> Int in
                    return board.pieces[w][j]
                })).count == 1
                
                let w2_range = Set(Array(0 ..< self.size - self.size + 1).map({ (k) -> Int in
                    return board.pieces[w + k][h + k]
                })).count == 1
                
                let h2_range = Set(Array(self.size - self.size + 1 ..< self.size).map({ (l) -> Int in
                    return board.pieces[w + l][h + l]
                })).count == 1
                
                let is_empty_piece = board.pieces[w][h] != 0
                
                if contains_w && is_empty_piece && w_range {
                    return Double(board.pieces[w][h])
                } else if contains_h && is_empty_piece && h_range {
                    return Double(board.pieces[w][h])
                } else if contains_w && contains_h && is_empty_piece && w2_range {
                    return Double(board.pieces[w][h])
                } else if contains_w && contains_h && is_empty_piece && h2_range {
                    return Double(board.pieces[w][h])
                }
            }
        }
        
        if b.has_legal_moves() {
            return 0.0
        }
        
        return 1e-4
    }
    
    func get_valid_moves(board: Board, player: Int) -> [Int] {
        var valids = Array.init(repeating: 0, count: self.action_size)
        let b = Board(size: self.size)
        b.pieces = board.pieces
        let legal_moves = b.get_legal_moves(player: player)
        if legal_moves.isEmpty {
            valids[-1] = 1
            return valids
        }
        for (x, y) in legal_moves {
            valids[self.size * x + y] = 1
        }
        return valids
    }
}
