class Game
  def initialize
    
  end
end

class Board
  def initialize(width=9, height=9, total_bombs=10)
    @width, @height, @total_bombs = width, height, total_bombs
    build_board
  end
  
  def build_board
    @board = Array.new(@height) { Array.new(@width)}
    #@height.times do |x|
    
  end
  
end

class Tile
  def initialize
    
  end
  
end