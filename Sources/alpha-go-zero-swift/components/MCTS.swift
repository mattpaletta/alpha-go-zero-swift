//
//  MCTS.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

fileprivate let FIRST_PLAYER = 1
fileprivate let SECOND_PLAYER = 2
fileprivate let GAME_ENDED = 0
fileprivate let EPS = 10 ^ (-8)

class MCTS {
    private let game: Game
    private let nnet: NNet
    private let num_mcst_sims: Int
    private let c_puct: Int
    private let root_noise: Bool
    private let board_size: Int
    
    private let Qsa: [(String, Int): Double] = [:] // stores Q values for s,a (as defined in the paper)
    private let Nsa: [(String, Int): Double] = [:] // stores #times edge s,a was visited
    private let Ns: [String: Int] = [:]  // stores #times board s was visited
    private var Ps: [String: [Double]] = [:]  // stores initial policy (returned by neural net)
    
    
    private var Es: [String: Int] = [:]  // stores game.getGameEnded ended for board s
    private let Vs: [String: [Int]] = [:]  // stores game.getValidMoves for board s
    private var num_every_mode_valid = 0
    
    
    init(game: Game, nnet: NNet, num_mcst_sims: Int, c_puct: Int, root_noise: Bool, board_size: Int) {
        self.game = game
        self.nnet = nnet
        self.num_mcst_sims = num_mcst_sims
        self.c_puct = c_puct
        self.root_noise = root_noise
        self.board_size = board_size
    }
    
    func get_action_prob(board: Board, temp: Int = 1, iteration: Int = 0) -> [Double] {
        for i in 0 ..< self.num_mcst_sims {
            print("Starting MCST Simlulation: \(i+1)/\(self.num_mcst_sims):\(iteration)")
            self.search(board: board, root_noise: self.root_noise)
        }
        
        let s = self.game.as_string(board: board)
        var counts: [Double] = Array(0..<self.game.action_size).map { (a) -> Double in
            guard let a = self.Nsa[s] else { return 0.0 }
            return a
        }
        
        var probs: [Double] = Array.init(repeating: 0.0, count: counts.count)
        
        if temp == 0 {
            print("No knowledge, choosing action with most visits")
            let best_action = counts.argmax()
            for id in best_action {
                probs[id] = 1.0
            }
        } else {
            print("Scaling counts for actions")
            counts = counts ^ Double(1.0 / Double(temp))
            probs = counts * (1.0 / Double(counts.reduce(0, +)))
        }
        
        return probs
    }
    
    private func search(board: Board, root_noise: Bool = false) {
        let _ = self.search(board: board, root_noise: root_noise, episolon: 0.25, dirichelet: 0.03)
    }
    
    private func search(board: Board, root_noise: Bool = false, episolon: Double = 0.25, dirichelet: Double = 0.03) -> Int {
        let board_string = self.game.as_string(board: board)
        
        if !self.Es.keys.contains(board_string) {
            self.Es.updateValue(self.game.get_game_ended(board: board, player: FIRST_PLAYER), forKey: board_string)
        }
        
        if self.Es[board_string]! != GAME_ENDED {
            return -self.Es[board_string]!
        }
        
        if !self.Ps.keys.contains(board_string) {
            print("Reached leaf node!")
            let (action_prob, board_value) = self.nnet.predict(board: board)
            self.Ps.updateValue(action_prob, forKey: board_string)
            
            let valids = self.game.get_valid_moves(board: board, player: FIRST_PLAYER)
            self.Ps.updateValue(self.Ps[board_string]! * valids, forKey: board_string)
            let sum_Ps_s = self.Ps[board_string]!.reduce(0, +)
        }
        
        return 1
    }
    
    
}
