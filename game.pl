% Computer player "thinks" and makes a move
computer_turn(Player, BoardState, BoardSize, NewBoardState):-
    difficulty_level(Level),
    alphabeta(Player, Level, BoardState:0, -10000, 10000, NewBoardState:_),
    display_board(BoardSize, NewBoardState),
    nl,
    not(is_game_over(Player, NewBoardState)),
    other_player(Player, OtherPlayer),
    human_player_turn(OtherPlayer, NewBoardState, BoardSize, _).

% Player is asked to make a move, selected move is made
human_player_turn(Player, BoardState, BoardSize, NewBoardState):-
    pick_ball_to_move(BoardState, Player, Row, Column),
    pick_possible_move(BoardState, Player, Row, Column, Direction),
    move(BoardState, Player, Row, Column, Direction, NewBoardState:_),
    display_board(BoardSize, NewBoardState),
    nl,
    not(is_game_over(Player, NewBoardState)),
    press_to_continue,
    nl,
    other_player(Player, OtherPlayer),
    computer_turn(OtherPlayer, NewBoardState, BoardSize, _).


% Repeatedly plays turns of players (human, computer, human...) until someone wins
run_game():-
    writeln("Welcome to Abalone!"),
    writeln("You can type exit anytime you want to finish the game."),
    pick_difficulty_level(_),
    pick_board_size(BoardSize),
    init_board(BoardSize, BoardState),
    display_board(BoardSize, BoardState),
    nl,
    human_player_turn(white, BoardState, BoardSize, _).

% Matches if the Player won the game (his score is 6 or above)
is_game_over(Player, BoardState):-
    score(Player, BoardState, Score),
    (
        Score >= 6,
        format("Game over! The ~w player won!", [Player]);
        fail
    ), !.

% Matches when score equals the number of balls the player managed to push over
score(Player, BoardState, Score):-
    other_player(Player, OtherPlayer),
    slot_legend(BallColor, OtherPlayer),
    findall(
        Row:Col,
        slot_by_index(BoardState, Row, Col, BallColor),
        OtherPlayerBalls
    ),
    length(OtherPlayerBalls, OtherPlayerBallsCount),
    board_size(BoardSize),
    balls_amount_by_board_size(BoardSize, BallsAmount),
    Score is BallsAmount - OtherPlayerBallsCount.
