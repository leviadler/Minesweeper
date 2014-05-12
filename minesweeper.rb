class Game
  def initialize
    setup_game
  end
  
  def setup_game
    puts "Please choose difficulty: "
    puts "1) Easy (9x9)"
    puts "2) Intermediate (16x16)"
    puts "3) Expert (16x30)"
    print "==> "
    
    level = gets.chomp.to_i
    
    until level > 0 && level < 4
      puts "Invalid input. Please choose a number between 1-3, inclusive."
      print "==> "
      level = gets.chomp.to_i
    end
    
    # We received valid input
    @game_board = Board.new if level == 1
    @game_board = Board.new(16,16,40) if level == 2
    @game_board = Board.new(30,16,99) if level == 3
    
    @game_board.display_board
    
  end
  
end

class Board
  #for testing
  attr_reader :board
  
  def initialize(width=9, height=9, total_bombs=10)
    @width, @height, @total_bombs = width, height, total_bombs
    build_board
  end
  
  def display_board
    #
    @height.times do |x|
      @width.times do |y|
        print @board[x][y].symbol + ' '
      end
      print "\n"
    end
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
    
    #display_board
    
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
       neighbor.first < @height && neighbor.last < @width
    end
    
  end
   
  def seed_board
    bomb_count = 0
    until bomb_count == @total_bombs
      # stop seeding if all tiles == bombs
      break if bomb_count == @height * @width
      # Get random coordinate
      x , y = rand(0...@height), rand(0...@width)
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
  attr_writer :bomb, :flagged, :revealed
  
  def initialize(coords)
    @coords = coords
    @bomb = false
    @neighbors = []
    @neighbor_bomb_count = 0
    @flagged = false
    @revealed = false
  end
  
  def bomb?
    @bomb
  end
  
  def flagged?
    @flagged
  end
  
  def revealed?
    @revealed
  end
  
  def hidden?
    !(@flagged) && !(@revealed)
  end
  
  def symbol
    return "*" if hidden?
    return "F" if flagged?
    @neighbor_bomb_count > 0 ? @neighbor_bomb_count.to_s : "_"
  end
  
end