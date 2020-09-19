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
        ['B', 'B', -1],
        [0, 0, 0],
        [-1, 'W', 'W']
    ].

slot_legend('W', white).
slot_legend('B', black).
slot_legend('.', empty).

player(white).
player(black).

% x ----------
direction(1, 0).
direction(-1, 0).
% y //////////
direction(1, -1).
direction(-1, 1).
% z \\\\\\\\\\
direction(1, 1).
direction(-1, -1).

axis(x, direction(1, 0)).
axis(y, direction(1, -1)).
axis(z, direction(1, 1)).

% TODO: less hard-coded, more logical
opposite_direction(direction(1, 0), direction(-1, 0)).
opposite_direction(direction(-1, 0), direction(1, 0)).
opposite_direction(direction(1, -1), direction(-1, 1)).
opposite_direction(direction(-1, 1), direction(1, -1)).
opposite_direction(direction(1, 1), direction(-1, -1)).
opposite_direction(direction(-1, -1), direction(1, 1)).

direction_in_axis(A, direction(X,Y)):-
    axis(A, direction(X,Y))
    ;
    (
        opposite_direction(direction(X,Y), direction(W,V)),
        axis(A, direction(W,V))
    ).

% TODO
% slot(Num, Letter)

% TODO
% % matches slot's color, depends on board state
% % slot_color(Board, Slot, Color)
% slot_color(Board, slot(Num, Letter), color(Color)).

% TODO
% % matches slot that contain a white ball, depends on board state
% % white_ball(Board, Slot)
% white_ball(Board, slot(Num, Letter)).

% TODO
% % matches slots that contain a black ball, depends on board state
% % black_ball(Board, Slot)
% black_ball(Board, slot(Num, Letter)).

% TODO
% % matches slots that contain no ball, depends on board state
% % no_ball(Board, Slot)
% no_ball(Board, slot(Num, Letter)).


% TODO
% % matches all slots of specified row
% row(slot(Num, Letter), axis(X, Y), Slots).

% TODO
% % size of row of given slot, in given axis
% row_size(slot(Num, Letter), axis(X, Y), Size).

% TODO
% % matches if all slots are aligned in same axis
% is_directed_array_of_slots(Slots, axis(X, Y)).

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
