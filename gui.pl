% Display the board's current state
display_board(BoardSize, BoardState):-
    display_top_border(BoardSize, BoardState),
    nl,
    display_current_board(1, BoardSize, BoardState),
    nl,
    display_bottom_border(BoardSize).

% Display the board's top border: including the top indices (A, B...) and the separator line
display_top_border(BoardSize, BoardState):-
    SpaceLimit is floor(BoardSize / 2) + 8,
    print_char_repeat(' ', 1, SpaceLimit),
    IndexLimit is ceil(BoardSize / 2),
    print_index_row('A', 1, IndexLimit),
    write("\t\t\t Computer's score: "),
    score(black, BoardState, BlackScore),
    write(BlackScore),
    nl,
    SlashLimit is SpaceLimit - 1,
    print_char_repeat(' ', 1, SlashLimit),
    print_pointers_row(BoardSize),
    write("\t\t\t       Your score: "),
    score(white, BoardState, WhiteScore),
    write(WhiteScore),
    nl,
    SeparatorLimit is SlashLimit - 2,
    print_char_repeat(' ', 1, SeparatorLimit),
    print_separator_row(BoardSize).

% Print the line of '/' in the board's top border
print_pointers_row(BoardSize):-
    HalfBoard is ceil(BoardSize / 2),
    print_char_repeat('/ ', 1, HalfBoard),
    NextCharCode is HalfBoard + 65,
    char_code(NextIndexChar, NextCharCode),
    write(' '),
    write(NextIndexChar).

% Print the line of '-' that indicates the beginning of the game board itself
print_separator_row(BoardSize):-
    SeparatorLimit is BoardSize + 1,
    print_char_repeat('-', 1, SeparatorLimit),
    write('  / '),
    HalfBoard is ceil(BoardSize / 2),
    NextCharCode is HalfBoard + 66,
    char_code(NextIndexChar, NextCharCode),
    write(NextIndexChar).

% Prints the same character 'Char' for 'Limit' times
print_char_repeat(Char, CurrentIndex, Limit):-
    write(Char),
    CurrentIndex < Limit, !,
    NextIndex is CurrentIndex + 1,
    print_char_repeat(Char, NextIndex, Limit).

print_char_repeat(_, Limit, Limit).

% Print the row of top indices (A, B and etc)
print_index_row(Char, CurrentIndex, Limit):-
    write(Char),
    write(' '),
    CurrentIndex < Limit, !,
    NextIndex is CurrentIndex + 1,
    char_code(Char, CharCode),
    NextCharCode is CharCode + 1,
    char_code(NextChar, NextCharCode),
    print_index_row(NextChar, NextIndex, Limit).

print_index_row(_, Limit, Limit).

% Display the board's current state
display_current_board(CurrentRow, BoardSize, BoardState):-
    print_row(CurrentRow, BoardSize, BoardState),
    CurrentRow < BoardSize, !,
    NextRow is CurrentRow + 1,
    nl,
    display_current_board(NextRow, BoardSize, BoardState).

display_current_board(BoardSize, BoardSize, _).

% Print a single row in the current game board
print_row(CurrentRow, BoardSize, BoardState):-
    HalfBoard is ceil(BoardSize / 2),
    Digits is div(CurrentRow, 10),
    SpacesLimit is abs(HalfBoard - CurrentRow) - Digits + 1,
    print_char_repeat(' ', 1, SpacesLimit),
    write(CurrentRow),
    write('-'),
    print_start_row_separator(CurrentRow, HalfBoard),
    nth0(CurrentRow, BoardState, RowState),
    print_row_state(RowState),
    print_end_row_separator(CurrentRow, BoardSize).

% Print the board's row according to its state,
% Skip the -1 slots indicating excluded slots
print_row_state([-1|RestOfSlots]):-
    print_row_state(RestOfSlots), !.

% Print the board's row according to its current state
print_row_state([CurrentSlot|RestOfSlots]):-
    (
        CurrentSlot = 0, write('.'), !;
        write(CurrentSlot)
    ),
    write(' '),
    print_row_state(RestOfSlots).

print_row_state([]):- !.

% Print the separator that indicates the beginning of a row in the board
print_start_row_separator(CurrentRow, HalfBoard):-
    (
        CurrentRow < HalfBoard, write('/ ');
        CurrentRow == HalfBoard, write('| ');
        write('\\ ')
    ).

% Print the separator that indicates the end of a row in the board
print_end_row_separator(CurrentRow, BoardSize):-
    HalfBoard is ceil(BoardSize / 2),
    (
        CurrentRow < HalfBoard,
        write('\\'),
        NextCharCode is HalfBoard + CurrentRow + 66,
        NextCharCode < 66 + BoardSize,
        write('  / '),
        NextCharCode < 65 + BoardSize,
        char_code(NextIndexChar, NextCharCode),
        write(NextIndexChar);
        CurrentRow == HalfBoard, write('| ');
        CurrentRow > HalfBoard, write('/ ');
        true
    ).

% Print the bottom border of the board
display_bottom_border(BoardSize):-
    SpaceLimit is ceil(BoardSize / 2) + 4,
    print_char_repeat(' ', 1, SpaceLimit),
    SeparatorLimit is BoardSize + 1,
    print_char_repeat('-', 1, SeparatorLimit).

% Display a list of given moves as an indexed list
print_moves(MoveIndex, SourceRow, SourceColLetter, [CurrentMove|Moves]):-
    CurrentMove = _-(PossibleRow:PossibleCol),
    write(MoveIndex), write(": "),
    col_num_to_letter(PossibleCol, PossibleColLetter),
    write(SourceRow), write(SourceColLetter), write(" -> "),
    write(PossibleRow), write(PossibleColLetter),
    nl,
    NextMoveIndex is MoveIndex + 1,
    print_moves(NextMoveIndex, SourceRow, SourceColLetter, Moves), !.

print_moves(_, _, _, []):- !.
