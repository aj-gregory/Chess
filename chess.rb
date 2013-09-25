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
    lay_board#_test #FIX THIS
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

  def lay_board_test
    @squares[3][4] = Rook.new(:white)
    @squares[3][1] = Bishop.new(:white)
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
    @squares.each do |row|
      display = ""
      row.each do |square|
        if square.is_a?(Piece)
          #p square
          #p square.get_char(square.color)
          display += square.get_char(square.color)
          display += "   "
        else
          display += "_   "
        end
      end
      puts display.encode('utf-8')
    end
  end

  def valid_move?(start_loc, end_loc)
    return false unless get_possible_moves(start_loc).include?(end_loc)
    return false if king_in_check?(start_loc, end_loc)
    true
  end

  def get_possible_moves(start_loc)
    piece = @squares[start_loc[0]][start_loc[1]]
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
    @move_dir = self.get_move_dir# e.g. horizontal, diagonal, vertical
    @char = self.get_char(color)
  end
end

class SlidingPiece < Piece
  def moves(board, start_loc)
    #creates array of positions to slide to based on board and move_dir
    # move_dir[0]
    moves = []
    case @move_dir[0]
    when :orthogonal
      transposed_board = board.transpose
      transposed_row = transposed_board[start_loc[1]]
      row = board[start_loc[0]]
      p transposed_row
      moves += get_north_moves(transposed_row, start_loc)
      moves += get_south_moves(transposed_row, start_loc)
      moves += get_east_moves(row, start_loc)
      moves += get_west_moves(row, start_loc)
    when :diagonal
      moves << get_nw_moves(board, start_loc)
      moves << get_ne_moves(board, start_loc)
      moves << get_sw_moves(board, start_loc)
      moves << get_se_moves(board, start_loc)
    end
    moves
  end

  def get_north_moves(row, start_loc)
    start_loc = start_loc.reverse
    sub_row = []
    moves = []

    row.each do |square|
      break if square == self
      sub_row << square
    end

   stepper = 1
    sub_row.reverse_each do |square_in_row|
      break if (start_loc[1] - stepper) < 0
      if square_in_row.is_a?(Piece)
        if square_in_row.color == self.color
          break
        else
          moves << [start_loc[0], (start_loc[1] - stepper)].reverse
        end
      else
        moves << [start_loc[0], (start_loc[1] - stepper)].reverse
        break
      end
      stepper += 1
    end
    moves
  end

  def get_south_moves(row, start_loc)
    start_loc = start_loc.reverse
    moves = []
    stepper = 1
    row.each_with_index do |square_in_row, idx|
      next if start_loc[1] >= idx
      break if (start_loc[1] + stepper) > 7
      if square_in_row.is_a?(Piece)
        if square_in_row.color == self.color
          break
        else
          moves << [start_loc[0], (start_loc[1] + stepper)].reverse
          break
        end
      else
        moves << [start_loc[0], (start_loc[1] + stepper)].reverse
      end
      stepper += 1
    end
    moves
  end


  def get_east_moves(row, start_loc)
    moves = []
    stepper = 1
    row.each_with_index do |square_in_row, idx|
      next if start_loc[1] >= idx
      break if (start_loc[1] + stepper) > 7
      if square_in_row.is_a?(Piece)
        p square_in_row.color
        p "Our color: #{self.color}"
        if square_in_row.color == self.color
          break
        else
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

  def get_west_moves(row, start_loc)
    sub_row = []
    moves = []

    row.each do |square|
      break if square == self
      sub_row << square
    end

   stepper = 1
    sub_row.reverse_each do |square_in_row|
      break if (start_loc[1] - stepper) < 0
      if square_in_row.is_a?(Piece)
        if square_in_row.color == self.color
          break
        else
          moves << [start_loc[0], (start_loc[1] - stepper)]
          break
        end
      else
        moves << [start_loc[0], (start_loc[1] - stepper)]
      end
      stepper += 1
    end
    moves
  end

end

class SteppingPiece < Piece
  def moves(board, start_loc)
  end
end

class Pawn < Piece
  attr_accessor :moved

  def initialize(color)
    @color = color
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

  def get_char(color)
    return "\u2659" if color == :white
    "\u265F" if color == :black
  end

end

class Queen < SlidingPiece
  def get_move_dir
    @move_dir = [:diagonal, :orthogonal]
  end

  def get_char(color)
   return "\u2655" if color == :white
    "\u265B" if color == :black
  end
end

class Bishop < SlidingPiece
  def get_move_dir
    @move_dir = [:diagonal]
  end

  def get_char(color)
    return "\u2657" if color == :white
    "\u265D" if color == :black
  end

end

class Rook < SlidingPiece
  def get_move_dir
    @move_dir = [:orthogonal]
  end

  def get_char(color)
    return "\u2656" if color == :white
    "\u265C" if color == :black
  end

end

class King < SteppingPiece
  def get_move_dir
    @move_dir = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end

  def get_char(color)
    return "\u2654" if color == :white
    "\u265A" if color == :black
  end
end

class Knight < SteppingPiece
  def get_move_dir
    @move_dir = [[1, 2], [2, 1], [1, -2], [2, -1], [-1, 2], [-2, 1], [-1, -2], [-2, -1]]
  end

  def get_char(color)
    return "\u2658" if color == :white
    "\u265E" if color == :black
  end

end

test_board = Board.new
test_board.display
#p test_board.get_possible_moves([3, 4])


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
