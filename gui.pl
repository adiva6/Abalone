display_board(BoardSize, BoardState):-
    display_top_border(BoardSize),
    nl,
    display_current_board(1, BoardSize, BoardState),
    nl,
    display_bottom_border(BoardSize).

display_top_border(BoardSize):-
    SpaceLimit is floor(BoardSize / 2) + 7,
    print_char_repeat(' ', 1, SpaceLimit),
    IndexLimit is ceil(BoardSize / 2),
    print_row_index('A', 1, IndexLimit),
    nl,
    SlashLimit is SpaceLimit - 1,
    print_char_repeat(' ', 1, SlashLimit),
    print_pointers_row(BoardSize),
    nl,
    DunderLimit is SlashLimit - 2,
    print_char_repeat(' ', 1, DunderLimit),
    print_separator_row(BoardSize).

print_pointers_row(BoardSize):-
    HalfBoard is ceil(BoardSize / 2),
    print_char_repeat('/ ', 1, HalfBoard),
    NextCharCode is HalfBoard + 65,
    char_code(NextIndexChar, NextCharCode),
    write(NextIndexChar).

print_separator_row(BoardSize):-
    print_char_repeat('-', 1, BoardSize),
    write('  / '),
    HalfBoard is ceil(BoardSize / 2),
    NextCharCode is HalfBoard + 66,
    char_code(NextIndexChar, NextCharCode),
    write(NextIndexChar).

print_char_repeat(Char, CurrentIndex, Limit):-
    write(Char),
    CurrentIndex < Limit, !,
    NextIndex is CurrentIndex + 1,
    print_char_repeat(Char, NextIndex, Limit).

print_char_repeat(_, Limit, Limit).

print_row_index(Char, CurrentIndex, Limit):-
    write(Char),
    write(' '),
    CurrentIndex < Limit, !,
    NextIndex is CurrentIndex + 1,
    char_code(Char, CharCode),
    NextCharCode is CharCode + 1,
    char_code(NextChar, NextCharCode),
    print_row_index(NextChar, NextIndex, Limit).

print_row_index(_, Limit, Limit).

display_current_board(CurrentRow, BoardSize, BoardState):-
    print_row(CurrentRow, BoardSize, BoardState),
    CurrentRow < BoardSize, !,
    NextRow is CurrentRow + 1,
    nl,
    display_current_board(NextRow, BoardSize, BoardState).

display_current_board(BoardSize, BoardSize, _).

print_row(CurrentRow, BoardSize, BoardState):-
    HalfBoard is ceil(BoardSize / 2),
    Digits is div(CurrentRow, 10),
    SpacesLimit is abs(HalfBoard - CurrentRow) - Digits + 1,
    print_char_repeat(' ', 1, SpacesLimit),
    write(CurrentRow),
    write('-'),
    print_start_row_separator(CurrentRow, HalfBoard),
    SlotsAmount is BoardSize - abs(HalfBoard - CurrentRow) - 1,
    print_char_repeat('. ', 1, SlotsAmount),
    print_end_row_separator(CurrentRow, BoardSize).

print_start_row_separator(CurrentRow, HalfBoard):-
    (
        CurrentRow < HalfBoard, write('/ ');
        CurrentRow == HalfBoard, write('| ');
        write('\\ ')
    ).

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

display_bottom_border(BoardSize):-
    SpaceLimit is ceil(BoardSize / 2) + 3,
    print_char_repeat(' ', 1, SpaceLimit),
    print_char_repeat('-', 1, BoardSize).