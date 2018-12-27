// original code https://github.com/mattpaletta/alphago-zero

// MCTS
let TEMP_THRESHOLD = 15
let NUM_MCTS_SIMS = 1600
let C_PUCT = 1

// NNET
let ROOT_NOISE = false
let NETWORK_ARCHITECTURE = 1
let LOG_DEVICE_PLACEMENT = false
let DROPOUT_RATE = 0.3
let BATCH_SIZE = 16
let NUM_CHANNELS = 256
let LEARNING_RATE = 0.001
let NUM_EPOCHS = 10
let CHECHPOINT_DIR = "./checkpoints"
let LOAD_MODEL = false
let load_folder_file = ["models/8x100x50", "best.pth.tar"]

// TRAIN
//let NUM_ITERS = 100
let NUM_ITERS = 10
//let NUM_EPISODES = 1000
let NUM_EPISODES = 10


// ARENA
let ARENA_SIZE = 40
let UPDATE_THRESHOLD = 0.6

// OTHER
let MAX_LEN_OF_QUEUE = 10_000
let NUM_ITERS_FOR_TRAIN_EXAMPLES_HISTORY = 20
let NUM_THREADS = 20
let BOARD_SIZE = 9
let LOAD_EXAMPLES = false


let game = Game(size: BOARD_SIZE)
let nnet = NNet(board_size: game.action_size, action_size: game.action_size)
let pnet = NNet(board_size: game.action_size, action_size: game.action_size)

let coach = Coach(game: game,
                  nnet: nnet,
                  pnet: pnet,
                  num_iters: NUM_ITERS,
                  root_noise: ROOT_NOISE,
                  board_size: BOARD_SIZE,
                  load_examples: LOAD_EXAMPLES)

print("Hello world!")
coach.learn(training_examples: NUM_EPISODES,
            keep_training_examples: MAX_LEN_OF_QUEUE,
            checkpoint_folder: CHECHPOINT_DIR,
            arena_tournament_size: ARENA_SIZE,
            model_update_win_threshold: UPDATE_THRESHOLD,
            num_mcst_sims: NUM_MCTS_SIMS,
            c_puct: C_PUCT,
            know_nothing_training_iters: TEMP_THRESHOLD,
            max_cpus: NUM_THREADS)
