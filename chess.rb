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
  attr_reader :squares # HERE FOR DEBUGGERY
  def initialize
    @squares = Array.new(8) { Array.new(8) }
    lay_board
  end

  def lay_board
    @squares[1].map! do |pawn_square|
      pawn_square = Pawn.new(:black)
    end

    @squares[6].map! do |pawn_square|
      pawn_square = Pawn.new(:white)
    end

    lay_pieces(0, :black)
    lay_pieces(7, :white)
  end

  def lay_pieces(row, color)
    @squares[row][0] = Rook.new(color)
    @squares[row][1] = Knight.new(color)
    @squares[row][2] = Bishop.new(color)
    @squares[row][3] = King.new(color)
    @squares[row][4] = Queen.new(color)
    @squares[row][5] = Bishop.new(color)
    @squares[row][6] = Knight.new(color)
    @squares[row][7] = Rook.new(color)
  end

  def display
    p squares
  end

  def valid_move?(start_loc, end_loc)
    return false unless get_possible_moves(start_loc).include?(end_loc)
    return false if king_in_check?(start_loc, end_loc)
    true
  end

  def get_possible_moves(start_loc)
    piece = @squares[start_loc]
    piece.moves(@squares, start_loc)
  end

  def king_in_check?

  end
  #game_over?
    #call checkmate?
  #checkmate?
    #checkmate if one player has no valid moves
  #valid_move?(pos, piece)
    #HELPERS
      #possible_moves(pos, piece)
        # if piece is pawn, check if there is enemy piece diagonal forward, if there is, pass it true
          # so it can add it to move_dir
      #king_in_check?(pos, piece)
        #dup Board
        #check for check
  #update(pos, piece)
    #move piece to new position
end

class Piece
  attr_reader :color

  def initialize(color)
    @color = color
    @move_dir = [] # e.g. horizontal, diagonal, vertical
  end
end

class SlidingPiece < Piece
  def moves(board, start_loc)
    #creates array of positions to slide to based on board and move_dir
    # move_dir[0]
    moves = []
    case move_dir[0]
    when :orthogonal
      row = board[start_loc[0]]
      moves << get_orthogonal_moves(row.transpose.reverse, start_loc)
      moves << get_orthogonal_moves(row.transpose, start_loc)
      moves << get_orthogonal_moves(row, start_loc)
      moves << get_orthogonal_moves(row.reverse, start_loc)
    when :diagonal
      moves << get_nw_moves(board, start_loc)
      moves << get_ne_moves(board, start_loc)
      moves << get_sw_moves(board, start_loc)
      moves << get_se_moves(board, start_loc)
    end
    moves
  end

  def get_orthogonal_moves(row, start_loc)
    moves = []
    row.each_with_index do |square_in_row, idx|
      next if start_loc[1] >= idx
      stepper = 1
      if square_in_row.is_a?(Piece)
        if square_in_row.color == self.color
          break
        elsif square_in_row.color != self.color
          moves << [start_loc[0], (start_loc[1] + stepper)]
          break
        end
      else
        moves << [start_loc[0], (start_loc[1] + stepper)]
      end
      stepper += 1
    end
    moves
  end

  def get_north_moves(board, start_loc)
    north_moves = []

    north_moves
  end
end

class SteppingPiece < Piece
  def moves(board, start_loc)
  end
end

class Pawn < Piece
  attr_accessor :moved

  def initialize(color)
    @moved = false
    @move_dir = get_move_dir(false)
  end

  def get_move_dir(opponent_diagonal)
    move_dir = []
    if @moved
      move_dir = [1, 0]
    else
      move_dir = [[2, 0], [1, 0]]
    end
    if opponent_diagonal
      move_dir << [[1, 1], [1, -1]]
    end
    move_dir
  end
end

class Queen < SlidingPiece
  def initialize(color)
    @move_dir = [:diagonal, :orthogonal]
  end
end

class Bishop < SlidingPiece
  def initialize(color)
    @move_dir = [:diagonal]
  end
end

class Rook < SlidingPiece
  def initialize(color)
    @move_dir = [:orthogonal]
  end
end

class King < SteppingPiece
  def initialize(color)
    @move_dir = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

class Knight < SteppingPiece
  def initialize(color)
    @move_dir = [[1, 2], [2, 1], [1, -2], [2, -1], [-1, 2], [-2, 1], [-1, -2], [-2, -1]]
  end
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
