class Game
  def initialize
    @board =  Board.new
  end

  def play_game
    #loop until game over (call game_over? from board)
    #play_turn
  end

  def play_turn

  end

end

class Board
  #game_over?
    #call checkmate?
  #checkmate?
    #checkmate if one player has no valid moves
  #valid_move?(pos, piece)
    #HELPERS
      #possible_moves(pos, piece)
      #king_in_check?(pos, piece)
        #dup Board
        #check for check
  #update(pos, piece)
    #move piece to new position
end

class Piece
end

class SlidingPiece < Piece
end

class SteppingPiece < Piece
end

class Pawn < Piece
end

class Queen < SlidingPiece
end

class King < SteppingPiece
end

class Bishop < SlidingPiece
end

class Knight < SteppingPiece
end

class Rook < SlidingPiece
end


#get move
#first position should contain piece of own color
#check for kind of piece
#can piece move to position2?
  #check how piece moves
  #generate potential move position (array of spots on board)
  #iterate trough possible spot array, make sure position2 is in array
  #check validity of move (does it put king in check?)
#move piece
  #update location of piece on board (contain this in Board class)
