:- dynamic board_size/1.

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

letter_to_col_num(Letter, ColNum):-
    char_code(Letter, LetterCode),
    ColNum is LetterCode - 64.

col_num_to_letter(ColNum, Letter):-
    LetterCode is ColNum + 64,
    char_code(Letter, LetterCode).

% matches slot content, depends on board state
slot_by_index(BoardState, RowIndex, ColIndex, SlotType):-
    nth0(RowIndex, BoardState, RowSlotTypes),
    nth0(ColIndex, RowSlotTypes, SlotType).

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

% matches all slots of specified row
row(BoardState, RowIndex, Row):-
    nth0(RowIndex, BoardState, Row).

% matches all slots of specified column
% column(BoardState, ColIndex, Column)
column(BoardState, ColIndex, Column):-
    column(BoardState, 0, ColIndex, Column).

column(BoardState, RowIndex, ColIndex, [SlotType|SlotTypes]):-
    board_size(BoardSize),
    RowIndex < BoardSize, !,
    NextRowIndex is RowIndex + 1,
    slot_by_index(BoardState, RowIndex, ColIndex, SlotType),
    column(BoardState, NextRowIndex, ColIndex, SlotTypes).


column(BoardState, RowIndex, ColIndex, [SlotType, -1]):-
    board_size(RowIndex),
    slot_by_index(BoardState, RowIndex, ColIndex, SlotType).

% Matches all slots of specified diagonal row
diagonal(BoardState, DiagonalIndex, Diagonal):-
    (
    	board_size(BoardSize),
    	HalfSize is ceil(BoardSize / 2),
        DiagonalIndex < HalfSize, 
        FirstRowIndex is HalfSize - DiagonalIndex,
        diagonal(BoardState, FirstRowIndex, 0, Diagonal), !
    );
    (
      	board_size(BoardSize),
      	HalfSize is ceil(BoardSize / 2),
        FirstColIndex is DiagonalIndex - HalfSize,
        diagonal(BoardState, 0, FirstColIndex, Diagonal), !
    ).

diagonal(BoardState, SlotRow, SlotCol, [SlotType|SlotTypes]):-
    board_size(BoardSize),
    (
        SlotRow < BoardSize,
        SlotCol < BoardSize
    ), !,
    slot_by_index(BoardState, SlotRow, SlotCol, SlotType),
    NextSlotRow is SlotRow + 1,
    NextSlotCol is SlotCol + 1,
    diagonal(BoardState, NextSlotRow, NextSlotCol, SlotTypes).

diagonal(BoardState, SlotRow, SlotCol, [SlotType, -1]):-
    (
        board_size(SlotRow);
        board_size(SlotCol)
    ),
    slot_by_index(BoardState, SlotRow, SlotCol, SlotType).

diagonal_index_by_slot(SlotRow, SlotCol, Index):-
    (SlotRow > 0, SlotCol > 0), !,
    PrevSlotRow is SlotRow - 1,
    PrevSlotCol is SlotCol - 1,
    diagonal_index_by_slot(PrevSlotRow, PrevSlotCol, Index).

diagonal_index_by_slot(SlotRow, SlotCol, Index):-
    (
        SlotRow = 0;
        SlotCol = 0
    ),
    (
        SlotCol = 0, !,
        board_size(BoardSize),
        HalfSize is ceil(BoardSize / 2),
        Index is HalfSize + SlotRow
    );
    (
        board_size(BoardSize),
        HalfSize is ceil(BoardSize / 2),
        Index is HalfSize - SlotCol
    ).

diagonal_by_slot(BoardState, SlotRow, SlotCol, Diagonal):-
    diagonal_index_by_slot(SlotRow, SlotCol, DiagonalIndex),
    diagonal(BoardState, DiagonalIndex, Diagonal).

next_slot_location(SlotRow, SlotCol, direction(X,Y), NextSlotRow, NextSlotCol):-
    NextSlotRow is SlotRow + X,
    NextSlotCol is SlotCol + Y.

