require 'yaml'

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
    @squares[7][3] = King.new(:white)
    @squares[6][3] = Rook.new(:white)
    @squares[5][3] = Rook.new(:black)
   # @squares[1][3].moved = true
  end

  def lay_pieces(row, color)
    @squares[row][0] = Rook.new(color)
    @squares[row][1] = Knight.new(color)
    @squares[row][2] = Bishop.new(color)
    @squares[row][3] = Queen.new(color)
    @squares[row][4] = King.new(color)
    @squares[row][5] = Bishop.new(color)
    @squares[row][6] = Knight.new(color)
    @squares[row][7] = Rook.new(color)
  end

  def display
    @squares.each do |row|
      display = ""
      row.each do |square|
        if square.is_a?(Piece)
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
    p "Passed possible moves"
    return false if own_king_in_check?(start_loc, end_loc)
    p "Passed king in check"
    true
  end

  def get_possible_moves(start_loc)
    piece = @squares[start_loc[0]][start_loc[1]]
    piece.moves(@squares, start_loc)
  end

  def own_king_in_check?(start_loc, end_loc)
    dup_board = self.dup

    piece = dup_board.squares[start_loc[0]][start_loc[1]]

    if dup_board.check?(piece.color)
      return true
    end

    false
  end

  def locate_pieces(color)
    pieces = {}
    @squares.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        if square.is_a?(Piece) && square.color == color
          pieces[square] =[row_idx, square_idx]
        end
      end
    end
    pieces
  end

  def locate_king(color)
    @squares.each_with_index do |row, row_idx|
      row.each_with_index  do |square, square_idx|
        if square.is_a?(King) && square.color == color
          #p "Before return"
          return {square => [row_idx, square_idx]}
        end
      end
    end
    nil
  end

  def dup
    serialized_board = self.to_yaml
    YAML::load(serialized_board)
  end

  def update(start_loc, end_loc)
    if valid_move?(start_loc, end_loc)
      @squares[end_loc[0]][end_loc[1]] = @squares[start_loc[0]][start_loc[1]]
      @squares[start_loc[0]][start_loc[1]] = nil
    end
  end

  def check?(color)
    our_king = locate_king(color)

     if color == :white
       opponent_color = :black
     else
       opponent_color = :white
     end

     opponent_pieces = locate_pieces(opponent_color)
     #p opponent_pieces

     opponent_pieces.each do |opponent_piece, opponent_location|
       if opponent_piece.moves(@squares, opponent_location).include?(our_king.values.flatten)
         return true
       end
     end
   false
  end

  def checkmate?(color)
    if !check?(color)
      return false
    else
      our_pieces = locate_pieces(color)

      our_pieces.each do |piece, location|
        piece.moves(@squares,).each do |piece_move|
          if valid_move?(location, piece_move)
            return false
          end
        end
      end
    end
    true
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
    @move_dir = self.get_move_dir
    @char = self.get_char(color)
  end

  def took_piece?(board, temp_loc)
    square_to_check = board[temp_loc[0]][temp_loc[1]]
    if square_to_check.is_a?(Piece) && square_to_check.color != self.color
      return true
    end
    false
  end

  def blocked?(board, temp_loc)
    square_to_check = board[temp_loc[0]][temp_loc[1]]
    if square_to_check.is_a?(Piece) && square_to_check.color == self.color
      return true
    end
    false
  end

  def off_board?(temp_loc)
    return true if temp_loc[0] > 7
    return true if temp_loc[0] < 0
    return true if temp_loc[1] > 7
    return true if temp_loc[1] < 0
    false
  end

end

class SlidingPiece < Piece
  def moves(board, start_loc)
    moves = []

    @move_dir.each do |vector|
      temp_loc = start_loc.dup
      while true
        temp_loc[1] = temp_loc[1] + vector[1]
        temp_loc[0] = temp_loc[0] + vector[0]

        break if off_board?(temp_loc)
        break if blocked?(board, temp_loc)

        moves << temp_loc.dup
        break if took_piece?(board, temp_loc)
      end
    end
    moves
  end

end

class SteppingPiece < Piece
  def moves(board, start_loc)
    moves = []

    @move_dir.each do |vector|
      temp_loc = start_loc.dup
      temp_loc[1] = temp_loc[1] + vector[1]
      temp_loc[0] = temp_loc[0] + vector[0]

      next if off_board?(temp_loc)
      next if blocked?(board, temp_loc)

      moves << temp_loc.dup
    end
    moves
  end

end


class Pawn < Piece
  attr_accessor :moved

  def initialize(color)
    @color = color
    @moved = false
    @move_dir = get_move_dir(false)
  end

  def moves(board, start_loc)
    moves = []
    opponent_diag = opponent_diagonal(board, start_loc)

    @move_dir = get_move_dir(opponent_diag)

    @move_dir.each do |vector|
      temp_loc = start_loc.dup
      temp_loc[1] = temp_loc[1] + vector[1]
      temp_loc[0] = temp_loc[0] + vector[0]

      next if off_board?(temp_loc)

      break if blocked?(board, temp_loc)

      moves << temp_loc.dup
    end
    moves
  end

  def find_location(board)
    board.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        return [row_idx, square_idx] if square == self
      end
    end
    nil
  end

  def opponent_diagonal(board, start_loc)

    if @color == :black
      square_to_left = board[start_loc[0] + 1][start_loc[1] + 1]
      square_to_right = board[start_loc[0] + 1][start_loc[1] - 1]
    else
      square_to_left = board[start_loc[0] - 1][start_loc[1] + 1]
      square_to_right = board[start_loc[0] - 1][start_loc[1] - 1]
    end

    if square_to_left.is_a?(Piece) && square_to_left.color != @color
      return {true => :left}
    end
    if square_to_right.is_a?(Piece) && square_to_right.color != @color
      return {true => :right}
    end

    nil
  end

  def blocked?(board, temp_loc)
    my_loc = find_location(board)
    is_diag = false
    if @color == :black
      if my_loc[0] + 1 == temp_loc[0] && my_loc[1] + 1 == temp_loc[1]
        is_diag = true
      end
      if my_loc[0] + 1 == temp_loc[0] && my_loc[1] - 1 == temp_loc[1]
        is_diag = true
      end
    else
      if my_loc[0] - 1 == temp_loc[0] && my_loc[1] + 1 == temp_loc[1]
        is_diag = true
      end
      if my_loc[0] - 1 == temp_loc[0] && my_loc[1] - 1 == temp_loc[1]
        is_diag = true
      end
    end

    square_to_check = board[temp_loc[0]][temp_loc[1]]
    if is_diag
      if square_to_check.is_a?(Piece) && square_to_check.color == @color
        return true
      end
    else
      if square_to_check.is_a?(Piece)
        return true
      end
    end
    false
  end

  def get_move_dir(opponent_diag)
    move_dir = []

    if opponent_diag
      if @color == :black
        if opponent_diag[true] == :left
          move_dir << [1, 1]
        else
          move_dir << [1, -1]
        end
      else
        if opponent_diag[true] == :left
          move_dir << [-1, 1]
        else
          move_dir << [-1, -1]
        end
      end
    end

    if @moved
      if @color == :black
      move_dir << [1, 0]
      else
        move_dir << [-1, 0]
      end
    else
      if @color == :black
        move_dir << [1, 0]
        move_dir << [2, 0]
      else
        move_dir << [-1, 0]
        move_dir << [-2, 0]
      end
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
    @move_dir = [[0, 1], [1, 1], [1, 0], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]]
  end

  def get_char(color)
   return "\u2655" if color == :white
    "\u265B" if color == :black
  end
end

class Bishop < SlidingPiece
  def get_move_dir
    @move_dir = [[1, 1], [-1, 1], [-1, -1], [1, -1]]
  end

  def get_char(color)
    return "\u2657" if color == :white
    "\u265D" if color == :black
  end

end

class Rook < SlidingPiece
  def get_move_dir
    @move_dir = [[0, 1], [1, 0], [-1, 0], [0, -1]]
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
#  p test_board.valid_move?
p test_board.update([6, 5], [5, 5])
puts
puts
puts
test_board.display
p test_board.update([1, 4], [3, 4])
puts
puts
puts
test_board.display
p test_board.update([6, 6], [4, 6])
puts
puts
puts
test_board.display
p test_board.update([0, 3], [4, 7])
puts
puts
puts
test_board.display
p test_board.checkmate?(:white)

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
