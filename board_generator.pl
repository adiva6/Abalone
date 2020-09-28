
% -------------------------------------------------------------------------------
% Import necessary modules
:- [board, gui].
% -------------------------------------------------------------------------------

init_board(BoardSize, InitialBoard):-
    MatrixSize is BoardSize + 2,
    generate_list(1, MatrixSize, -1, FirstRow),
    generate_black_side(BoardSize, BlackRows),
    NumberOfEmptyRows is BoardSize - 6,
    generate_empty_rows(0, NumberOfEmptyRows, BoardSize, EmptyRows),
    generate_white_side(BoardSize, WhiteRows),
    generate_list(1, MatrixSize, -1, LastRow),
    long_conc([[FirstRow], BlackRows, EmptyRows, WhiteRows, [LastRow]], InitialBoard).

% generate board after a left / right move
generate_changed_board(BoardState, FirstChangedSlotRow, FirstChangedSlotCol, direction(0, Y), NextSlotsSequence, NextBoardState):-
    board_size(BoardSize),
    % Get before & after rows
    BeforeRowIndex is FirstChangedSlotRow - 1,
    AfterRowIndex is FirstChangedSlotRow + 1,
    BottomBorderIndex is BoardSize + 1,
    findall(
        Row, 
        (row(BoardState, RowIndex, Row), between(0, BeforeRowIndex, RowIndex)), 
        BeforeRows
    ),
    findall(
        Row, 
        (row(BoardState, RowIndex, Row), between(AfterRowIndex, BottomBorderIndex, RowIndex)), 
        AfterRows
    ),

    % Generate changed row
    slots_sequence_by_direction(BoardState, BoardSize, FirstChangedSlotRow, FirstChangedSlotCol, direction(0, Y), CurrSlotTypes),
    row(BoardState, FirstChangedSlotRow, ChangedRow),
    ((
        Y > 0, !,
        append([UnchangedSlotTypes, CurrSlotTypes], ChangedRow), !,
        append([UnchangedSlotTypes, NextSlotsSequence], NextEffectedRow)
    )
    ;
    (
        reverse(NextSlotsSequence, OrientedNextSlotsSequence),
        reverse(CurrSlotTypes, OrientedCurrSlotTypes),
        append([OrientedCurrSlotTypes, UnchangedSlotTypes], ChangedRow), !,
        append([OrientedNextSlotsSequence, UnchangedSlotTypes], NextEffectedRow)
    )),
    % Build board state from rows
    long_conc([BeforeRows, [NextEffectedRow], AfterRows], NextBoardState).

% TODO: support other directions
% generate_changed_board(BoardState, FirstChangedSlotRow, FirstChangedSlotCol, direction(X, Y), NextSlotsSequence, NextBoardState):-
% X /= 0.

long_conc([], []). % Concatenation of an empty list is an empty list
long_conc([[]|ListsTail], ResultTail):- % First list in the list of lists is empty
    long_conc(ListsTail, ResultTail).
long_conc([[X|FirstListTail]|ListsTail], [X|ResultTail]):- % First list in the list of lists contains more than one element
    long_conc([FirstListTail|ListsTail], ResultTail).

balls_amount_by_board_size(BoardSize, BallsAmount):-
    BallsAmount is BoardSize + ceil(BoardSize / 2).

generate_empty_rows(CurrentRowNumber, NumberOfRows, BoardSize, [Row|Rows]):-
    CurrentRowNumber < NumberOfRows, !,
    Row = [-1|Slots],
    Length is BoardSize - abs(ceil(NumberOfRows / 2) - CurrentRowNumber - 1) + 1,
    generate_list(1, Length, 0, Slots),
    NextRowNumber is CurrentRowNumber + 1,
    generate_empty_rows(NextRowNumber, NumberOfRows, BoardSize, Rows), !.

generate_empty_rows(NumberOfRows, NumberOfRows, _, []):- !.

generate_black_side(BoardSize, [Row1, Row2, Row3]):-
    Row1 = [-1|Slots1],
    Row2 = [-1|Slots2],
    Row3 = [-1|Slots3],
    Row1BallsNumber is ceil(BoardSize / 2),
    generate_balls(0, BoardSize, Row1BallsNumber, Row1BallsNumber, 'B', Slots1),
    Row2BallsNumber is Row1BallsNumber + 1,
    generate_balls(0, BoardSize, Row2BallsNumber, Row2BallsNumber, 'B', Slots2),
    Row3Size is Row2BallsNumber + 1,
    balls_amount_by_board_size(BoardSize, BallsAmount),
    Row3BallsNumber is BallsAmount - Row1BallsNumber - Row2BallsNumber,
    generate_balls(0, BoardSize, Row3Size, Row3BallsNumber, 'B', Slots3).

generate_white_side(BoardSize, [Row3, Row2, Row1]):-
    Row1Reversed = [-1|Slots1],
    Row2Reversed = [-1|Slots2],
    Row3Reversed = [-1|Slots3],
    Row1BallsNumber is ceil(BoardSize / 2),
    generate_balls(0, BoardSize, Row1BallsNumber, Row1BallsNumber, 'W', Slots1),
    Row2BallsNumber is Row1BallsNumber + 1,
    generate_balls(0, BoardSize, Row2BallsNumber, Row2BallsNumber, 'W', Slots2),
    Row3Size is Row2BallsNumber + 1,
    balls_amount_by_board_size(BoardSize, BallsAmount),
    Row3BallsNumber is BallsAmount - Row1BallsNumber - Row2BallsNumber,
    generate_balls(0, BoardSize, Row3Size, Row3BallsNumber, 'W', Slots3),
    reverse(Row1, Row1Reversed),
    reverse(Row2, Row2Reversed),
    reverse(Row3, Row3Reversed), !.

generate_balls(CurrentIndex, BoardSize, RowSize, BallsNumber, BallColor, [Slot|Slots]):-
    CurrentIndex < RowSize,
    (
    	(
        	BallsNumber = RowSize, !,
        	Slot = BallColor
    	);
    	(
        	EmptySlots is RowSize - BallsNumber,
        	StartOfBalls is EmptySlots / 2,
        	EndOfBalls is StartOfBalls + BallsNumber - 1,
        	between(StartOfBalls, EndOfBalls, CurrentIndex), !,
        	Slot = BallColor
    	);
    	(
        	Slot = 0
    	)
    ),
    NextIndex is CurrentIndex + 1,
    generate_balls(NextIndex, BoardSize, RowSize, BallsNumber, BallColor, Slots), !.

generate_balls(CurrentIndex, BoardSize, RowSize, BallsNumber, BallColor, [-1|Slots]):-
    CurrentIndex =< BoardSize,
    NextIndex is CurrentIndex + 1,
    generate_balls(NextIndex, BoardSize, RowSize, BallsNumber, BallColor, Slots), !.

generate_balls(CurrentIndex, BoardSize, _, _, _, []):-
    CurrentIndex > BoardSize, !.

generate_list(CurrentIndex, Length, Content, [Content|Slots]):-
    CurrentIndex < Length, !,
    NextIndex is CurrentIndex + 1,
    generate_list(NextIndex, Length, Content, Slots).

generate_list(Length, Length, _, [-1]).
