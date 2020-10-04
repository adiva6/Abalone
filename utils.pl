other_player(white, black).
other_player(black, white).

letter_to_col_num(Letter, ColNum):-
    char_code(Letter, LetterCode),
    ColNum is LetterCode - 64.

col_num_to_letter(ColNum, Letter):-
    LetterCode is ColNum + 64,
    char_code(Letter, LetterCode).