require 'yaml'

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
    return false if own_king_in_check?(start_loc, end_loc)
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
        piece_loc = piece.find_location(@squares)
        piece.moves(@squares, piece_loc).each do |piece_move|
          if valid_move?(location, piece_move)
            return false
          end
        end
      end
    end
    true
  end

  def game_over?
    return true if checkmate?(:white) || checkmate?(:black)
  end

end