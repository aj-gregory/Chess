require 'yaml'

class Board

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
    print "   "
    0.upto(7) {|num| print "#{num}   "}
    puts
    @squares.each_with_index do |row, idx|
      print " #{idx} "
      display = ""
      row.each do |square|
        if square.is_a?(Piece)
          display += square.get_char(square.color)
          display += "   "
        else
          display += "-   "
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
    piece = find_piece(start_loc)
    piece.moves(@squares, start_loc)
  end

  def own_king_in_check?(start_loc, end_loc)
    dup_board = self.dup

    piece = dup_board.find_piece(start_loc)

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

  def update(start_loc, end_loc, turn)
    if find_piece(start_loc).nil?
      raise "No piece there"
    end
    if find_piece(start_loc).color != turn
      raise "Not your piece"
    end
    if valid_move?(start_loc, end_loc)
      @squares[end_loc[0]][end_loc[1]] = find_piece(start_loc)
      @squares[start_loc[0]][start_loc[1]] = nil
    else
      raise "Invalid move"
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

  def find_piece(location)
    @squares.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        return square if row_idx == location[0] && square_idx == location[1]
      end
    end
    nil
  end

end