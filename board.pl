:- dynamic board_size/1.
% TODO: bigger board, this is a stub.
%           A B C
%          / / /
%        ---
%    1-/ B B \
%   2-| . . . |
%   3- \ W W /
%        ---

init_board(3, EmptyBoard):- 
    EmptyBoard = [
        [-1 , -1 , -1 , -1 , -1],
        [-1 , 'B', 'B', -1 , -1],
        [-1 ,  0 ,  0 ,  0 , -1],
        [-1 , -1 , 'W', 'W', -1],
        [-1 , -1 , -1 , -1 , -1]
    ].

slot_legend('W', white).
slot_legend('B', black).
slot_legend(0, empty).
slot_legend(-1, border).

player(white).
player(black).
other_player(white, black).
other_player(black, white).

% x ----------
direction(1, 0).
direction(-1, 0).
% y //////////
direction(0, 1).
direction(0, -1).
% z \\\\\\\\\\
direction(1, 1).
direction(-1, -1).

axis(x, direction(1, 0)).
axis(y, direction(0, 1)).
axis(z, direction(1, 1)).

% TODO: less hard-coded, more logical
opposite_direction(direction(1, 0), direction(-1, 0)).
opposite_direction(direction(-1, 0), direction(1, 0)).
opposite_direction(direction(0, 1), direction(0, -1)).
opposite_direction(direction(0, -1), direction(0, 1)).
opposite_direction(direction(1, 1), direction(-1, -1)).
opposite_direction(direction(-1, -1), direction(1, 1)).

direction_in_axis(A, direction(X,Y)):-
    axis(A, direction(X,Y))
    ;
    (
        opposite_direction(direction(X,Y), direction(W,V)),
        axis(A, direction(W,V))
    ).

letter_to_row(L, I):-
    char_code(L, LCode),
    I is LCode - 64.

% matches slot content, depends on board state
slot_by_index(BoardState, RowIndex, ColIndex, Slot):-
    nth0(RowIndex, BoardState, RowSlots),
    nth0(ColIndex, RowSlots, Slot).

% matches slot that contain a white ball, depends on board state
white_ball(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, 'W').

% matches slots that contain a black ball, depends on board state
black_ball(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, 'B').

% matches slots that contain no ball, depends on board state
no_ball(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, 0).

% matches border slots, depends on board state (though this remains static throughout the game)
border(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, -1).

% matches all slots of specified horizontal row
horizontal_row(BoardState, RowIndex, Slots):-
    nth0(RowIndex, BoardState, Slots).

% matches all slots of specified vertical row
% vertical_row(BoardState, ColIndex, Slots)
vertical_row(BoardState, ColIndex, Slots):-
    vertical_row(BoardState, 0, ColIndex, Slots).

vertical_row(BoardState, RowIndex, ColIndex, [Slot|Slots]):-
    board_size(BoardSize),
    RowIndex < BoardSize, !,
    NextRowIndex is RowIndex + 1,
    slot_by_index(BoardState, RowIndex, ColIndex, Slot),
    vertical_row(BoardState, NextRowIndex, ColIndex, Slots).


vertical_row(BoardState, RowIndex, ColIndex, [Slot, -1]):-
    board_size(RowIndex),
    slot_by_index(BoardState, RowIndex, ColIndex, Slot).

% matches all slots of specified diagonal row
diagonal_row(BoardState, RowIndex, Slots):-
    (
    	board_size(BoardSize),
    	HalfSize is ceil(BoardSize / 2),
        RowIndex < HalfSize, 
        FirstRowIndex is HalfSize - RowIndex,
        diagonal_row(BoardState, FirstRowIndex, 0, Slots), !
    );(
      	board_size(BoardSize),
      	HalfSize is ceil(BoardSize / 2),
        FirstColIndex is RowIndex - HalfSize,
        diagonal_row(BoardState, 0, FirstColIndex, Slots), !
    ).

diagonal_row(BoardState, RowIndex, ColIndex, [Slot|Slots]):-
    board_size(BoardSize),
    (RowIndex < BoardSize, ColIndex < BoardSize), !,
    slot_by_index(BoardState, RowIndex, ColIndex, Slot),
    NextRowIndex is RowIndex + 1,
    NextColIndex is ColIndex + 1,
    diagonal_row(BoardState, NextRowIndex, NextColIndex, Slots).

diagonal_row(BoardState, RowIndex, ColIndex, [Slot, -1]):-
    (board_size(RowIndex);board_size(ColIndex)),
    slot_by_index(BoardState, RowIndex, ColIndex, Slot).

diagonal_row_index_by_slot(SlotRow, SlotCol, Index):-
    (SlotRow > 0, SlotCol > 0), !,
    PrevSlotRow is SlotRow - 1,
    PrevSlotCol is SlotCol - 1,
    diagonal_row_index_by_slot(PrevSlotRow, PrevSlotCol, Index).

diagonal_row_index_by_slot(SlotRow, SlotCol, Index):-
    (SlotRow = 0 ; SlotCol = 0), !, 
    (
        SlotCol = 0,
        board_size(BoardSize),
        HalfSize is ceil(BoardSize / 2),
        Index is HalfSize + SlotRow
    );(
        board_size(BoardSize),
        HalfSize is ceil(BoardSize / 2),
        Index is HalfSize - SlotCol
    ).

diagonal_row_by_slot(BoardState, SlotRow, SlotCol, Slots):-
    diagonal_row_index_by_slot(SlotRow, SlotCol, RowIndex),
    diagonal_row(BoardState, RowIndex, Slots).


next_slot_location(SlotRow, SlotCol, direction(X,Y), NextSlotRow, NextSlotCol):-
    NextSlotRow is SlotRow + X,
    NextSlotCol is SlotCol + Y.

legal_move(PlayerColor, [C, C, C, O, O, N]):-
    validate_colors(PlayerColor, C,O,N), !.

legal_move(PlayerColor, [C, C, C, O, N]):-
    validate_colors(PlayerColor, C,O,N), !.

legal_move(PlayerColor, [C, C, C, N]):-
    validate_colors(PlayerColor, C,_,N), !.

legal_move(PlayerColor, [C, C, O, N]):-
    validate_colors(PlayerColor, C,O,N), !.

legal_move(PlayerColor, [C, C, N]):-
    validate_colors(PlayerColor, C,_,N), !.

legal_move(PlayerColor, [C, N]):-
    validate_colors(PlayerColor, C,_,N), !.


validate_colors(PlayerColor, C,O,N):-
    slot_legend(C, PlayerColor),
    (slot_legend(N, empty) ; slot_legend(N, border)),
    other_player(PlayerColor, OtherPlayerColor),
    slot_legend(O, OtherPlayerColor).


% TODO
% % alters board state and player scores if necessary
% make_move(move(FirstBall, Direction)).

% % TODO
% % a "move" object, defines a legal move
% move(BoardState, PlayerColor, RowIndex, ColIndex, Direction, NextBoardState).
