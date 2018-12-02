//
//  MCTS.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

class MCTS {
    init(game: Game, nnet: NNet, num_mcst_sims: Int, c_puct: Int, root_noise: Bool, board_size: Int) {
        
    }
    
    func get_action_prob(board: Board, temp: Int, iteration: Int = 0) -> [Float] {
        return [0.0]
    }
}
