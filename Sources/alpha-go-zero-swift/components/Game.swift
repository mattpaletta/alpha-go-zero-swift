//
//  Game.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

//let np = Python.import("numpy")

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
        self.init(size: 5)
    }
    
    convenience init(size: Int) {
        self.init(size: size, history: 5)
    }
    
    func get_init_board() -> Board {
        let board = Board(size: self.size)
        return board
    }
    
    func get_canonical_form(board: Board, player: Int) -> Board {
        return board.get_canonical_form(player: player)
    }
    
    func get_symmetries(board: Board, pi: [Float]) -> [(board: Board, pi: Float)] {
        return [(board: board, pi: 0.0)]
    }
    
    func get_next_state(board: Board, player: Int, action: Int) -> (Board, Int) {
        return (board, player)
    }
    
    func get_game_ended(board: Board, player: Int) -> Int {
        return 0
    }
}
