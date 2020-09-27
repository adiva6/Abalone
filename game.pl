:- dynamic difficulty_level/1.
% -------------------------------------------------------------------------------
% Import necessary modules
:- [user_input, board, gui, board_generator, alpha_beta].
% -------------------------------------------------------------------------------

% Computer player "thinks" and makes a move
computer_turn(Player, BoardState, NewBoardState):-
    difficulty_level(Level),
    Depth is 3 * Level,
    alphabeta(Player, Depth, BoardState, -10000, 10000, NewBoardState, _),
    human_player_turn(Player, NewBoardState, _).

% Player is asked to make a move, selected move is made
human_player_turn(Player, BoardState, NewBoardState):-
    pick_ball_to_move(BoardState, Player, Row, Column),
    pick_possible_move(BoardState, Player, Row, Column, Direction),
    move(BoardState, Player, Row, Column, Direction, NewBoardState),
    other_player(Player, OtherPlayer),
    computer_turn(OtherPlayer, NewBoardState, _).


% Repeatedly plays turns of players (human, computer, human...) until someone wins
run_game():-
    writeln("Welcome to Abalone!"),
    pick_difficulty_level(_),
    pick_board_size(BoardSize),
    init_board(BoardSize, BoardState),
    display_board(BoardSize, BoardState),
    human_player_turn(white, BoardState, _).
