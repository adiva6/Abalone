% -------------------------------------------------------------------------------
% Import necessary modules
:- [user_input, board, gui, board_generator].
% -------------------------------------------------------------------------------

% Computer player "thinks" and makes a move
% TODO: method will use dfs to find move with best score, and call move(BestMove)
computer_turn():-
    % TODO: use bfs (/ dfs) to find best move
    % make_move(BestMove)
    !.

% Player is asked to make a move, selected move is made
human_player_turn(BoardState, NewBoardState):-
    pick_ball_to_move(BoardState, white, Row, Column),
    pick_possible_move(BoardState, white, Row, Column, Direction),
    move(BoardState, Row, Column, Direction, NewBoardState).


% Repeatedly plays turns of players (human, computer, human...) until someone wins
run_game():-
    writeln("Welcome to Abalone!"),
    pick_difficulty_level(_),
    pick_board_size(BoardSize),
    init_board(BoardSize, BoardState),
    display_board(BoardSize, BoardState),
    repeat,
    (
        human_player_turn(),
        computer_turn()
    ).
