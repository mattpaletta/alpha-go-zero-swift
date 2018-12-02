//
//  NNet.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation
class NNet {
    private let board_size_x: Int
    private let board_size_y: Int
    
    private let action_size: Int
//    private let learning_rate: Float
    private let dropout_rate: Float
    private let num_epochs: Int
    private let batch_size: Int
//    private let num_channels: Int
//    private let log_device_placement: Bool
    private let network_architecture: Int
    
    init(board_size: Int,
         action_size: Int,
         learning_rate: Float = 0.001,
         dropout_rate: Float = 0.3,
         epochs: Int = 10,
         batch_size: Int = 32,
         num_channels: Int = 256,
         log_device_placement: Bool = false,
         network_architecture: Int = 0) {
        self.board_size_x = board_size
        self.board_size_y = board_size
        self.action_size = action_size
        self.num_epochs = epochs
        self.batch_size = batch_size
        self.dropout_rate = dropout_rate
        
        self.network_architecture = network_architecture
    }
    
    
    func train(examples: [TrainExample]) {
        
    }
    
    func save_checkpoint(folder: String, filename: String) {
        
    }
    
    func load_checkpoint(folder: String, filename: String) {
        
    }
}
