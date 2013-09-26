require './board.rb'
require './pieces.rb'

class Game
  def initialize
    @board =  Board.new
  end

  def play_game
    until @board.game_over?
      puts "White turn: "
      @turn = :white
      @board.display
      play_turn
      break if @board.game_over?
      puts "Black turn: "
      @turn = :black
      @board.display
      play_turn
    end
    puts "Checkmate! #{@turn.to_s.capitalize} wins!"
  end

  def play_turn
    begin
      print "Choose a place to move from: (row, col) "
      start_loc = string_arr_to_int_arr(gets.chomp.split(", "))
      print "Choose a place to move to: (row, col) "
      end_loc = string_arr_to_int_arr(gets.chomp.split(", "))
      @board.update(start_loc, end_loc, @turn)
    rescue RuntimeError => e
      puts "Could not move from #{start_loc} to #{end_loc}"
      puts "Error was: #{e.message}"
      retry
    end
  end

  def string_arr_to_int_arr(string_arr)
    int_arr = []
    string_arr.each { |str| int_arr << str.to_i }
    int_arr
  end

end

test_game= Game.new
test_game.play_game
