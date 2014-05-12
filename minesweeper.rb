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
    
    build_neighbors
    
    seed_board
    
    set_neighbor_bomb_counts
    
    p @board
    
  end
  
  def build_neighbors
    
    @height.times do |x|
      @width.times do |y|
        tile = @board[x][y]
        tile.neighbors = get_neighbors(tile)
      end
    end
     
  end
  
  def get_neighbors(tile)
    deltas = [ [-1,-1], [0,-1], [1,-1],
               [-1,0],          [1,0],
               [-1, 1], [0,1],  [1,1]]
               
    neighbors = deltas.map do |delta|
      [tile.coords.first + delta.first,
        tile.coords.last + delta.last]
    end
    
    neighbors.select do |neighbor|
      neighbor.first >= 0 && neighbor.last >= 0 &&
       neighbor.first < @width && neighbor.last < @height
    end
    
  end
   
  def seed_board
    bomb_count = 0
    until bomb_count == @total_bombs
      # stop seeding if all tiles == bombs
      break if bomb_count == @height * @width
      # Get random coordinate
      x , y = rand(0...@width), rand(0...@height)
      unless @board[x][y].bomb?
        @board[x][y].bomb = true
        bomb_count += 1
      end
    end
  end
  
  def set_neighbor_bomb_counts
    @height.times do |x|
      @width.times do |y|
        tile = @board[x][y]
        bomb_count = 0
        tile.neighbors.each do |neighbor| 
          neighbor_tile = @board[neighbor.first][neighbor.last]
          bomb_count += 1 if neighbor_tile.bomb? 
        end
        tile.neighbor_bomb_count = bomb_count
      end
    end
  end
  
end

class Tile
  
  attr_reader :coords
  attr_accessor :neighbors, :neighbor_bomb_count
  attr_writer :bomb
  
  def initialize(coords)
    @coords = coords
    @bomb = false
    @neighbors = []
    @neighbor_bomb_count = 0
  end
  
  def bomb?
    @bomb
  end
  
end