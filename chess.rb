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
      puts "Black turn: "
      @turn = :black
      @board.display
      play_turn
    end
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

 #  test_board.display
# #  p test_board.valid_move?
# p test_board.update([6, 5], [5, 5])
# puts
# puts
# puts
# test_board.display
# p test_board.update([1, 4], [3, 4])
# puts
# puts
# puts
# test_board.display
# p test_board.update([6, 6], [4, 6])
# puts
# puts
# puts
# test_board.display
# p test_board.update([0, 3], [4, 7])
# puts
# puts
# puts
# test_board.display
# p test_board.checkmate?(:white)

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
