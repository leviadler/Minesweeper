class Game
  FLAGGED_ACTION = 2
  REVEAL_ACTION = 1
  
  def initialize
  end
  
  def setup_game
    level = get_level
    
    # We received valid input
    @game_board = Board.new if level == 1
    @game_board = Board.new(16,16,40) if level == 2
    @game_board = Board.new(30,16,99) if level == 3
    
  end
  
  def get_level
    puts "Please choose difficulty: "
    puts "1) Easy (9x9)"
    puts "2) Intermediate (16x16)"
    puts "3) Expert (16x30)"
    print "==> "
    
    level = gets.chomp.to_i
    
    until level.between?(1,3)
      puts "Invalid input. Please choose a number between 1-3, inclusive."
      print "==> "
      level = gets.chomp.to_i
    end
    
    level
  end
  
  def run
    setup_game
    @game_board.display_board
    
    until @game_board.over?
      
      begin
        row, col = get_user_coords
      rescue ArgumentError
        puts "Non-valid input"
        retry
      end
      
      action = get_user_action
      
      if action == FLAGGED_ACTION
        if @game_board.board[row][col].flagged?
          @game_board.board[row][col].flagged = false
        else
          @game_board.board[row][col].flagged = true
        end
      end
      
      @game_board.display_board
    end
    
  end
  
  def get_user_coords
    row, col = prompt_for_coords
    
    until row.between?(0,@game_board.height-1) &&
       col.between?(0,@game_board.width-1)
       puts "Invalid coordinate, please try again:"
       row, col = prompt_for_coords
    end
     
    if @game_board.board[row][col].revealed?
      puts "Tile already revealed, please try again:"
      row, col = prompt_for_coords
    end
    
    [row, col]
  end
  
  def prompt_for_coords
    puts "Please enter the row of your desired tile:"
    print "==>"
    row = Integer(gets.chomp)
 
    puts "Please enter the col of your desired tile:"
    print "==>"
    col = Integer(gets.chomp)
    
    [row, col]
  end
  
  def get_user_action
    puts "What action will you perform?\n1) Reveal\n2) Flag\n==>"
    action = gets.chomp.to_i
    
    until action.between?(1,2)
      puts "Invalid choice. Please enter either 1 or 2."
      print "==>"
      action = gets.chomp.to_i
    end
    action
  end
  
# end game class
end

class Board
  
  attr_reader :board, :height, :width
  
  def initialize(width=9, height=9, total_bombs=10)
    @width, @height, @total_bombs = width, height, total_bombs
    build_board
  end
  
  def over?
    # over if tile is bomb and revealed
    # over if all non-bomb tiles are revealed
    false
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