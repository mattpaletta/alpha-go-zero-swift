//
//  NNet.swift
//  alpha-go-zero-swift
//
//  Created by Matthew on 2018-12-01.
//

import Foundation
import MetalPerformanceShaders

class NNet {
    private let board_size_x: Int
    private let board_size_y: Int
    
    private let action_size: Int
//    private let learning_rate: Float
    private let dropout_rate: Double
    private let num_epochs: Int
    private let batch_size: Int
//    private let num_channels: Int
//    private let log_device_placement: Bool
    private let network_architecture: Int
    
    init(board_size: Int = 9,
         action_size: Int = 82,
         learning_rate: Double = 0.001,
         dropout_rate: Double = 0.3,
         epochs: Int = 10,
         batch_size: Int = 32, // 16
         num_channels: Int = 256,
         log_device_placement: Bool = false,
         network_architecture: Int = 1) {
        self.board_size_x = board_size
        self.board_size_y = board_size
        self.action_size = action_size
        self.num_epochs = epochs
        self.batch_size = batch_size
        self.dropout_rate = dropout_rate
        
        self.network_architecture = network_architecture
        self.buildModel(size_x: board_size, size_y: board_size, learning_rate: learning_rate, channels: num_channels, action_size: action_size)
    }
    
    private func buildModel(size_x: Int, size_y: Int, learning_rate: Double, channels: Int, action_size: Int) {
        let imageInput = MPSNNImageNode(handle: nil)
//        let x_image = tf.reshape(self.input_boards, [-1, board_size_x, board_size_y, 1])
    }
    
    func train(examples: [TrainExample]) {
        // Here we always use the tensorflow network
    }
    
    func predict(board: Board) -> ([Double], [Double]) {
        // Here we can dynamically change between the metal and tensorflow networks
        // Depending on the capability of the machine!
        assert(false, "NNet not implemented yet")
        return (Array.init(repeating: 0.0, count: board.size), Array.init(repeating: 0.0, count: board.size))
    }
    
    func save_checkpoint(folder: String, filename: String) {
        // Convert to metal weights too!
    }
    
    func load_checkpoint(folder: String, filename: String) {
        // Load metal weights too!
    }
}
