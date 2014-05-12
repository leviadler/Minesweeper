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
    
    # Initialize with tiles and their coordinates
    @height.times do |x|
      @width.times do |y|
        @board[x][y] = Tile.new([x,y])
      end
    end
    
    seed_board
    
    p @board
    
  end
  
  def seed_board
    bomb_count = 0
    until bomb_count == @total_bombs
      break if bomb_count == @height * @width
      # Get random coordinate
      x , y = rand(0...@width), rand(0...@height)
      unless @board[x][y].bomb
        @board[x][y].bomb = true
        bomb_count += 1
      end
    end
  end
  
end

class Tile
  
  attr_reader :coords 
  attr_accessor :bomb
  
  def initialize(coords)
    @coords = coords
    @bomb = false
  end
  
end