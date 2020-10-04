% -------------------------------------------------------------------------------
% Import board utilities
:- [board, utils].
% -------------------------------------------------------------------------------

possible_states(Player, BoardState, PossibleStates):-
    slot_legend(BallColor, Player),
    findall(NextBoardState,
            (
                slot_by_index(BoardState, Row, Col, BallColor),
                possible_moves_by_location(Player, BoardState, Row, Col, _, _, Direction),
                move(BoardState, Player, Row, Col, Direction, NextBoardState)
            ),
            PossibleStates).

% Matches for legal destinations given the current board state and
% the location of the marble to move.
possible_moves_by_location(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, direction(X, Y)):-
    direction(X, Y),
    possible_moves_by_direction(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, direction(X, Y)).

% Matches for a legal destination for a certain direction.
possible_moves_by_direction(Player, BoardState, SourceRow, SourceCol, DestRow, DestCol, Direction):-
    next_slot_location(SourceRow, SourceCol, Direction, DestRow, DestCol),
    legal_move(Player, BoardState, SourceRow, SourceCol, Direction).

% Matches for the slots following the location of the moving marble, according to the
% given direction.
slots_sequence_by_direction(BoardState, BoardSize, SourceRow, SourceCol, Direction, [SlotType|SlotTypes]):-
    LateralBorderRowIndex is BoardSize + 1,
    between(0, LateralBorderRowIndex, SourceRow),
    between(0, LateralBorderRowIndex, SourceCol), !,
    slot_by_index(BoardState, SourceRow, SourceCol, SlotType),
    next_slot_location(SourceRow, SourceCol, Direction, NextRowIndex, NextColIndex),
    slots_sequence_by_direction(BoardState, BoardSize, NextRowIndex, NextColIndex, Direction, SlotTypes), !.

slots_sequence_by_direction(_, BoardSize, SourceRow, SourceCol, _, []):-
    LateralBorderRowIndex is BoardSize + 1,
    (
        not(between(0, LateralBorderRowIndex, SourceRow));
        not(between(0, LateralBorderRowIndex, SourceCol))
    ).

% True if moving the marble in the source location towards the given direction
% is considered a legal move.
legal_move(Player, BoardState, SourceRow, SourceCol, Direction):-
    board_size(BoardSize),
    between(1, BoardSize, SourceRow),
    between(1, BoardSize, SourceCol),
    slots_sequence_by_direction(BoardState, BoardSize, SourceRow, SourceCol, Direction, Slots),
    legal_move(Player, Slots).

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, NoBall, _), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, NoBall, _), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, OtherPlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, NoBall, _), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border), !.

legal_move(PlayerColor, [PlayerBall, PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _), !.

legal_move(PlayerColor, [PlayerBall, NoBall | _]):-
    validate_colors(PlayerColor, PlayerBall, _, NoBall, _), !.

validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, NoBall, Border):-
    slot_legend(PlayerBall, PlayerColor),
    slot_legend(NoBall, empty),
    slot_legend(Border, border),
    other_player(PlayerColor, OtherPlayer),
    slot_legend(OtherPlayerBall, OtherPlayer).


killer_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border).

killer_move(PlayerColor, [PlayerBall, PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border).

killer_move(PlayerColor, [PlayerBall, PlayerBall, OtherPlayerBall, Border | _]):-
    validate_colors(PlayerColor, PlayerBall, OtherPlayerBall, _, Border).

% Move (can be used to make move by passing NextBoardState result back to game handler)
move(BoardState, PlayerColor, RowIndex, ColIndex, Direction, NextBoardState):-
    board_size(BoardSize),
    slots_sequence_by_direction(BoardState, BoardSize, RowIndex, ColIndex, Direction, EffectedSlotsState),
    move_slots_forward_in_line(PlayerColor, EffectedSlotsState, NextEffectedSlotsState),
    generate_changed_board(BoardState, RowIndex, ColIndex, Direction, NextEffectedSlotsState, NextBoardState).

% Matches a slots sequence's state to it's next state after a move forward
move_slots_forward_in_line(PlayerColor, CurrSlotsState, NextSlotsState):-
    % In both cases, an empty slot is revealed at the beginning of the sequnece
    member(0, CurrSlotsState),
    (
        % If there is an empty slot in the sequence, the balls before this slot will move forward to this slot
        append([MovedBalls, [0], StaticBalls], CurrSlotsState), !,
        append([[0], MovedBalls, StaticBalls], NextSlotsState)
    );
    (
        % Otherwise, last ball (of other player) will be removed, the rest will move forward
        other_player(PlayerColor, OtherPlayerColor),
        slot_legend(OtherPlayerBall, OtherPlayerColor),
        append([MovedBalls, [-1], Border], CurrSlotsState), !,
        select(OtherPlayerBall, MovedBalls, BallsLeftInGame), !,
        append([[0], BallsLeftInGame, [-1], Border], NextSlotsState)
    ).
