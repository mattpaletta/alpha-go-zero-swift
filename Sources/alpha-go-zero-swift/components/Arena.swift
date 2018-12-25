//
//  Arena.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

class Arena {
    
    private let player1: ((Board) -> Int)
    private let player2: ((Board) -> Int)
    private let game: Game
    
    init(player1: @escaping ((Board) -> Int),
         player2: @escaping ((Board) -> Int),
         game: Game) {
        self.player1 = player1
        self.player2 = player2
        self.game = game
    }
    
    func play_games(size: Int) -> (one: Int, two: Int, draws: Int) {
//        let max_episodes = size
//        let num = size / 2
        
        let results = Array(0..<(size)).pmap(transformer: run_arena).reduce(into: (one: 0, two: 0, draws: 0, episodes: 0)) { (result, arg1) in
            let (one, two, draws, eps) = arg1
            result.one += one
            result.two += two
            result.draws += draws
            result.episodes += eps
//            return (one: result.one + one, two: result.two + two, draws: result.draws + draws, episodes: result.episodes + eps)
        }
        
        print(results)
        return (one: results.one, two: results.two, draws: results.draws)
    }
    
    private func run_arena(i: Int) -> (one: Int, two: Int, draws: Int, eps: Int) {
        var one_won = 0
        var two_won = 0
        var draws = 0
        var eps = 0
        
        let game_result = self.play_game()
        if game_result == -1 {
            one_won += 1
        } else if game_result == 1 {
            two_won += 1
        } else {
            draws += 1
        }
        
        eps += 1
        if i % 2 == 0 {
            return (one: one_won, two: two_won, draws: draws, eps: eps)
        } else {
            return (one: two_won, two: one_won, draws: draws, eps: eps)
        }
    }
    
    private func play_game() -> Double {
        let players = [self.player2, nil, self.player1]
        let cur_player = 1
        let board = self.game.get_init_board()
        var it = 0
        while self.game.get_game_ended(board: board, player: cur_player) == 0 {
            it += 1
            let action = players[cur_player + 1]!(self.game.get_canonical_form(board: board, player: cur_player))
            let valids = self.game.get_valid_moves(board: self.game.get_canonical_form(board: board, player: cur_player), player: 1)
            if valids[action] == 0 {
                print(action)
                assert(valids[action] > 0)
            }
            
            var (board, cur_player) = self.game.get_next_state(board: board, player: cur_player, action: action)
        }
        
        print("Game Completed")
        return self.game.get_game_ended(board: board, player: 1)
    }
}
