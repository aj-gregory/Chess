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

  def find_location(board)
    board.each_with_index do |row, row_idx|
      row.each_with_index do |square, square_idx|
        return [row_idx, square_idx] if square == self
      end
    end
    nil
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
