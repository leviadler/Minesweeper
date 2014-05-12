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
    
    @height.times do |x|
      @width.times do |y|
        @board[x][y] = Tile.new([x,y])
      end
    end
    
    p @board
  end
  
end

class Tile
  
  attr_reader :coords
  
  def initialize(coords)
    @coords = coords
  end
  
end