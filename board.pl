% Create the initial board state according to the BoardSize
init_board(BoardSize, InitialBoard):-
    MatrixSize is BoardSize + 2,
    generate_list(1, MatrixSize, -1, FirstRow),
    generate_black_side(BoardSize, BlackRows),
    NumberOfEmptyRows is BoardSize - 6,
    generate_empty_rows(NumberOfEmptyRows, BoardSize, EmptyRows),
    generate_white_side(BoardSize, WhiteRows),
    generate_list(1, MatrixSize, -1, LastRow),
    append([[FirstRow], BlackRows, EmptyRows, WhiteRows, [LastRow]], InitialBoard).

% Generate board after a horizontal move
generate_changed_board(BoardState, FirstChangedSlotRow, FirstChangedSlotCol, direction(0, Y), NextSequence, NextBoardState):-
    board_size(BoardSize),
    % Get before & after rows
    LastBeforeRowIndex is FirstChangedSlotRow - 1,
    FirstAfterRowIndex is FirstChangedSlotRow + 1,
    LastAfterRowIndex is BoardSize + 1,
    findall(
        Row, 
        (between(0, LastBeforeRowIndex, RowIndex), row(BoardState, RowIndex, Row)), 
        BeforeRows
    ),
    findall(
        Row, 
        (between(FirstAfterRowIndex, LastAfterRowIndex, RowIndex), row(BoardState, RowIndex, Row)), 
        AfterRows
    ),

    % Generate changed row
    slots_sequence_by_direction(BoardState, BoardSize, FirstChangedSlotRow, FirstChangedSlotCol, direction(0, Y), CurrSequence),
    % Select changed row
    row(BoardState, FirstChangedSlotRow, ChangedRow),
    ((
        % If direction is positive, curr slot sequence is the rest of the changed line - just swap it with next sequence
        Y > 0, !,
        append([UnchangedSlotTypes, CurrSequence], ChangedRow), !,
        append([UnchangedSlotTypes, NextSequence], NextEffectedRow)
    )
    ;
    (
        % Else, orient curr and next slot sequences, and swap them, they are the beginning of the row.
        reverse(NextSequence, OrientedNextSequence),
        reverse(CurrSequence, OrientedCurrSequence),
        append([OrientedCurrSequence, UnchangedSlotTypes], ChangedRow), !,
        append([OrientedNextSequence, UnchangedSlotTypes], NextEffectedRow)
    )),
    % Build board state from rows
    append([BeforeRows, [NextEffectedRow], AfterRows], NextBoardState).

% Generate board after a vertical move
generate_changed_board(BoardState, FirstChangedSlotRow, FirstChangedSlotCol, direction(X, Y), NextSequence, NextBoardState):-
    X \= 0, !,
    board_size(BoardSize),
    length(NextSequence, NumOfChangedRows),
% Calculate last changed slot's row index (last in sequence, not necessarily bottom changed row),
% while omitting last row in sequence (border is static)
    LastChangedSlotRow is FirstChangedSlotRow + (X * (NumOfChangedRows - 2)),
    
    % Get before & after rows
    UpperChangedRow is min(FirstChangedSlotRow, LastChangedSlotRow),
    LowerChangedRow is max(FirstChangedSlotRow, LastChangedSlotRow),
    LastBeforeRowIndex is UpperChangedRow - 1,
    FirstAfterRowIndex is LowerChangedRow + 1,
    LastAfterRowIndex is BoardSize + 1,
    findall(
        Row, 
        (between(0, LastBeforeRowIndex, RowIndex), row(BoardState, RowIndex, Row)), 
        BeforeRows
    ),
    findall(
        Row, 
        (between(FirstAfterRowIndex, LastAfterRowIndex, RowIndex), row(BoardState, RowIndex, Row)), 
        AfterRows
    ),
    % Get changed rows (might be reversed, if direction is vertically negative)
    generate_changed_rows(BoardState, (FirstChangedSlotRow,FirstChangedSlotCol), direction(X,Y), NextSequence, NextChangedRows), !,
    ((
        X > 0, !,
        OrientedNextChangedRows = NextChangedRows
    );(
        reverse(NextChangedRows, OrientedNextChangedRows)
    )),
    % Concat the new oriented rows and unchanged rows and recieve the new board state
    append([BeforeRows, OrientedNextChangedRows, AfterRows], NextBoardState).

% Generates changed rows, ordered by vertical direction.
generate_changed_rows(BoardState, (RowIndex,ColIndex), direction(X,Y), [NextSlot|NextSlots], [NextChangedRow|NextChangedRows]):-
    NextSlots \= [], !,
    row(BoardState, RowIndex, CurrChangedRow),
    append([BeforeCols,[_], AfterCols], CurrChangedRow),
    length(BeforeCols, ColIndex),
    append([BeforeCols, [NextSlot], AfterCols], NextChangedRow),
    NextRowIndex is RowIndex + X,
    NextColIndex is ColIndex + Y,
    generate_changed_rows(BoardState, (NextRowIndex,NextColIndex), direction(X,Y), NextSlots, NextChangedRows).

% Last row is not changed, it's appended as part of the before/after rows
generate_changed_rows(_, _, _, [-1], []).

balls_amount_by_board_size(BoardSize, BallsAmount):-
    BallsAmount is BoardSize + ceil(BoardSize / 2).

generate_empty_rows(NumberOfRows, BoardSize, Rows):-
    HalfNumber is (NumberOfRows - 1) / 2,
    generate_first_empty_half(0, HalfNumber, BoardSize, FirstHalfRowsReversed),
    reverse(FirstHalfRowsReversed, FirstHalfRows),
    MiddleRow = [-1|Slots],
    generate_list(0, BoardSize, 0, Slots),
    generate_last_empty_half(0, HalfNumber, BoardSize, LastHalfRows),
    append([FirstHalfRows, [MiddleRow], LastHalfRows], Rows), !.

generate_first_empty_half(CurrentRowNumber, NumberOfRows, BoardSize, [Row|Rows]):-
    CurrentRowNumber < NumberOfRows, !,
    Row = [-1|Slots],
    NumberOfEmptySlots is BoardSize - CurrentRowNumber - 1,
    generate_empty_row(0, NumberOfEmptySlots, BoardSize, Slots),
    NextRowNumber is CurrentRowNumber + 1,
    generate_first_empty_half(NextRowNumber, NumberOfRows, BoardSize, Rows), !.

generate_first_empty_half(NumberOfRows, NumberOfRows, _, []):- !.

generate_empty_row(CurrentIndex, NumberOfEmptySlots, BoardSize, [Slot|Slots]):-
    CurrentIndex < NumberOfEmptySlots, !,
    Slot = 0,
    NextIndex is CurrentIndex + 1,
    generate_empty_row(NextIndex, NumberOfEmptySlots, BoardSize, Slots), !.

generate_empty_row(CurrentIndex, NumberOfEmptySlots, BoardSize, [-1|Slots]):-
    CurrentIndex =< BoardSize, !,
    NextIndex is CurrentIndex + 1,
    generate_empty_row(NextIndex, NumberOfEmptySlots, BoardSize, Slots), !.

generate_empty_row(CurrentIndex, _, BoardSize, []):-
    CurrentIndex > BoardSize, !.

generate_last_empty_half(CurrentRowNumber, NumberOfRows, BoardSize, [Row|Rows]):-
    CurrentRowNumber < NumberOfRows, !,
    ReversedRow = [-1|Slots],
    NumberOfEmptySlots is BoardSize - CurrentRowNumber - 1,
    generate_empty_row(0, NumberOfEmptySlots, BoardSize, Slots),
    reverse(ReversedRow, Row),
    NextRowNumber is CurrentRowNumber + 1,
    generate_last_empty_half(NextRowNumber, NumberOfRows, BoardSize, Rows), !.

generate_last_empty_half(NumberOfRows, NumberOfRows, _, []):- !.

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
