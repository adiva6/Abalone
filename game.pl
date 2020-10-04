:- dynamic difficulty_level/1.
% -------------------------------------------------------------------------------
% Import necessary modules
:- [user_input, board, gui, board_generator, alpha_beta].
% -------------------------------------------------------------------------------

% Computer player "thinks" and makes a move
computer_turn(Player, BoardState, BoardSize, NewBoardState):-
    difficulty_level(Level),
    Depth is 2 * Level,
    alphabeta(Player, Depth, BoardState, -10000, 10000, NewBoardState, _),
    display_board(BoardSize, NewBoardState),
    nl,
    not(is_game_over(Player, BoardState)),
    other_player(Player, OtherPlayer),
    human_player_turn(OtherPlayer, NewBoardState, BoardSize, _).

% Player is asked to make a move, selected move is made
human_player_turn(Player, BoardState, BoardSize, NewBoardState):-
    pick_ball_to_move(BoardState, Player, Row, Column),
    pick_possible_move(BoardState, Player, Row, Column, Direction),
    move(BoardState, Player, Row, Column, Direction, NewBoardState),
    not(is_game_over(Player, BoardState)),
    other_player(Player, OtherPlayer),
    computer_turn(OtherPlayer, NewBoardState, BoardSize, _).


% Repeatedly plays turns of players (human, computer, human...) until someone wins
run_game():-
    writeln("Welcome to Abalone!"),
    pick_difficulty_level(_),
    pick_board_size(BoardSize),
    init_board(BoardSize, BoardState),
    display_board(BoardSize, BoardState),
    nl,
    human_player_turn(white, BoardState, BoardSize, _).

% Matches if the Player won the game (6 of the opponent's balls were pushed over)
is_game_over(Player, BoardState):-
    other_player(Player, OtherPlayer),
    slot_legend(BallColor, OtherPlayer),
    findall(Row:Col,
            slot_by_index(BoardState, Row, Col, BallColor),
            OtherPlayerBalls),
    length(OtherPlayerBalls, OtherPlayerBallsCount),
    board_size(BoardSize),
    balls_amount_by_board_size(BoardSize, BallsAmount),
    (
        OtherPlayerBallsCount =< BallsAmount - 6,
        format("Game over! The ~w player won!", [Player]);
        fail
    ), !.
