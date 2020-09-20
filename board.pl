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


next_slot_location(SlotRow, SlotCol, direction(X,Y), NextSlotRow, NextSlotCol):-
    NextSlotRow is SlotRow + X,
    NextSlotCol is SlotCol + Y.

% TODO
% % MovedBalls array will be the set of balls which will be moved by a move
% moved_balls(move(FirstBall, direction(X, Y)), MovedBalls).

% TODO
% % matches for all moves that can be played by given player
% legal_move(Player, move(FirstSlot, Direction)).

% TODO
% % alters board state and player scores if necessary
% make_move(move(FirstBall, Direction)).

% TODO
% % a "move" object that defines a possible move
% move(FirstBall, Direction).

% TODO
% % matches for all balls which are owned by a player and aligned in a row, in any direction
% three_aligned_balls(Balls).
% two_aligned_balls(Balls).
