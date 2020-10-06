:- dynamic board_size/1.
:- dynamic difficulty_level/1.

other_player(white, black).
other_player(black, white).

letter_to_col_num(Letter, ColNum):-
    char_code(Letter, LetterCode),
    ColNum is LetterCode - 64.

col_num_to_letter(ColNum, Letter):-
    LetterCode is ColNum + 64,
    char_code(Letter, LetterCode).

slot_legend('W', white).
slot_legend('B', black).
slot_legend(0, empty).
slot_legend(-1, border).

% x ----------
direction(1, 0).
direction(-1, 0).
% y //////////
direction(0, 1).
direction(0, -1).
% z \\\\\\\\\\
direction(1, 1).
direction(-1, -1).

% Matches slot content, depends on board state
slot_by_index(BoardState, RowIndex, ColIndex, SlotType):-
    nth0(RowIndex, BoardState, RowSlotTypes),
    nth0(ColIndex, RowSlotTypes, SlotType).

% Matches slot that contain a white ball, depends on board state
white_ball(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, 'W').

% Matches slots that contain a black ball, depends on board state
black_ball(BoardState, RowIndex, ColIndex):-
    slot_by_index(BoardState, RowIndex, ColIndex, 'B').

% Matches all slots of specified row
row(BoardState, RowIndex, Row):-
    nth0(RowIndex, BoardState, Row).

% Matches the next slot of SlotRow:SlotCol in the given direction
next_slot_location(SlotRow, SlotCol, direction(X,Y), NextSlotRow, NextSlotCol):-
    NextSlotRow is SlotRow + X,
    NextSlotCol is SlotCol + Y.
