//
//  Coach.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation

class Coach {
    private let game: Game
    private let nnet: NNet
    private let pnet: NNet
    private let num_iters: Int
    private let root_noise: Bool
    private let board_size: Int
    
    private var elo = 1000
    private var previous_elos = [1000]
    private var doFirstIterSelfPlay = true
    
    init(game: Game,
         nnet: NNet,
         pnet: NNet,
         num_iters: Int,
         root_noise: Bool,
         board_size: Int,
         load_examples: Bool) {
        self.game = game
        self.nnet = nnet
        self.pnet = pnet
        self.num_iters = num_iters
        self.root_noise = root_noise
        self.board_size = board_size
        
        if load_examples {
            self.load_training_examples()
        }
    }
    
    private func load_training_examples() {
        
    }
    
    func learn(training_examples: Int,
               keep_training_examples: Int,
               checkpoint_folder: String,
               arena_tournament_size: Int,
               model_update_win_threshold: Double,
               num_mcst_sims: Int,
               c_puct: Int,
               know_nothing_training_iters: Int,
               max_cpus: Int) {
        print("Starting learning loop")
        var training_examples_history: [TrainExample] = []
        
        for i in 0 ..< self.num_iters {
            print("ITER: \(i + 1)/\(self.num_iters + 1)")
            if self.doFirstIterSelfPlay {
                print("Doing first iteration self play from configs")
            } else {
                print("Skipping first iteration self play from configs")
            }
            
            if self.doFirstIterSelfPlay || i > 0 {
                print("Starting \(training_examples)")
                
                // Run a parallel map on the new examples.
                // TODO:// Convert the network to Metal first!
                let iteration_train_examples = Array(0..<training_examples).pmap(transformer: { iteration in
                    return self.do_self_play(game: self.game,
                                      nnet: self.nnet,
                                      num_mcst_sims: num_mcst_sims,
                                      c_puct: c_puct,
                                      root_noise: self.root_noise,
                                      board_size: self.board_size,
                                      know_nothing_training_iters: know_nothing_training_iters,
                                      i: iteration)
                }).flatMap { example in
                    return example
                }
                
                training_examples_history.append(contentsOf: iteration_train_examples)
            } else {
                print("Skipped self play")
            }
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                self?.save_training_examples()
            }
            
            print("Flattening Training Examples")
            // TODO:// Flatten train_examples_history
            let train_examples: [TrainExample] = []
            
            if train_examples.count > keep_training_examples {
                print("Training examples limit exceeded: (\(training_examples_history)). Removing oldest examples.")
            }
            
            print("Shuffling \(train_examples.count) training examples")
            // TODO:// Shuffle array
            
            print("Saving this network, loading previous netowrk")
           
            let checkpoint_file = "temp.pth.tar"
            self.nnet.save_checkpoint(folder: checkpoint_folder,
                                      filename: checkpoint_file)
            self.pnet.load_checkpoint(folder: checkpoint_folder,
                                      filename: checkpoint_file)
            
            let prior_mcts = MCTS(game: self.game,
                                  nnet: self.pnet,
                                  num_mcst_sims: num_mcst_sims,
                                  c_puct: c_puct,
                                  root_noise: self.root_noise,
                                  board_size: self.board_size)
            
            print("Traning new network using shuffled training examples")
            self.nnet.train(examples: train_examples)
            let new_mcst = MCTS(game: self.game,
                                nnet: self.nnet,
                                num_mcst_sims: num_mcst_sims,
                                c_puct: c_puct,
                                root_noise: self.root_noise,
                                board_size: self.board_size)
            
            print("Testing network against previous version")
            let player1 = { (b: Board) in
                return prior_mcts.get_action_prob(board: b, temp: 0).argmax()
            }
            let player2 = { (b: Board) in
                return new_mcst.get_action_prob(board: b, temp: 0).argmax()
            }
            
            let arena = Arena(player1: player1, player2: player2, game: self.game)
            let (pwins, nwins, draws) = arena.play_games(size: arena_tournament_size)
            
            print("NEW/PREV WINS: \(nwins), \(pwins); DRAWS: \(draws)")
            
            let new_elo = self.calculate_new_elo(elo: self.elo, nwins: nwins, pwins: pwins)
            self.previous_elos.append(new_elo)
            print("Elo rating of the newest iteration: \(new_elo)")
            
            if pwins + nwins > 0 && Double(nwins) / Double(pwins + nwins) < model_update_win_threshold {
                print("Rejecting new model")
                self.nnet.load_checkpoint(folder: checkpoint_folder, filename: checkpoint_file)
            } else {
                print("Accepting new model")
                self.nnet.save_checkpoint(folder: checkpoint_folder, filename: self.get_examples_checkpoint_file(iteration: i))
                self.nnet.save_checkpoint(folder: checkpoint_folder, filename: "best.pth.tar")
                self.elo = new_elo
            }
            
            print("Elo at end of iteration: \(self.elo)")
        }
    }
    
    private func get_examples_checkpoint_file(iteration: Int) -> String {
        return ""
    }
    
    private func calculate_new_elo(elo: Int, nwins: Int, pwins: Int) -> Int {
        return 0
    }
    
    private func do_self_play(game: Game,
                              nnet: NNet,
                              num_mcst_sims: Int,
                              c_puct: Int,
                              root_noise: Bool,
                              board_size: Int,
                              know_nothing_training_iters: Int,
                              i: Int) -> [TrainExample] {
        let mcts = MCTS(game: game,
                        nnet: nnet,
                        num_mcst_sims: num_mcst_sims,
                        c_puct: c_puct,
                        root_noise: root_noise,
                        board_size: board_size)
        let train_examples = self.execute_episode(mcts: mcts,
                             know_nothing_training_iters: know_nothing_training_iters,
                             current_iteration_self_play: i)
        print("Done episode \(i) of self play.")
        return train_examples
    }
    
    private func save_training_examples() {
        assert(false, "finish implementing save_training_examples")
    }
    
    private func execute_episode(mcts: MCTS, know_nothing_training_iters: Int, current_iteration_self_play: Int) -> [TrainExample] {
        var train_examples: [TrainExample] = []
        let board = self.game.get_init_board()
        let cur_player = 1
        
        var episode_step = 0
        
        while true {
            episode_step += 1
            let canonical_board = self.game.get_canonical_form(board: board, player: cur_player)
            let temperature = (episode_step < know_nothing_training_iters).to_int()
            
            let pi = mcts.get_action_prob(board: canonical_board, temp: temperature, iteration: current_iteration_self_play)
            let symmetries = self.game.get_symmetries(board: canonical_board, pi: pi)
            
            for (board, pi_c) in symmetries {
                let b = Board(size: board.count)
                b.pieces = board
                train_examples.append((board: b, player: cur_player, pi: pi_c, a: nil))
            }
            
            let action = 0
            let (board, cur_player) = self.game.get_next_state(board: board,
                                                               player: cur_player,
                                                               action: action)
            
            let r = self.game.get_game_ended(board: board, player: cur_player)
            if r != 0 {
                return train_examples.map({ example in
                    return example
                })
            }
        }
    }
}
