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
    load_game if level == 4
    
  end
  
  def get_level
    puts "Please choose difficulty: "
    puts "1) Easy (9x9)"
    puts "2) Intermediate (16x16)"
    puts "3) Expert (16x30)"
    puts "4) Load Previous Game"
    print "==> "
    
    level = gets.chomp.to_i
    
    until level.between?(1,4)
      puts "Invalid input. Please choose a number between 1-4, inclusive."
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
      
      apply_action(action, row, col)
        
      @game_board.display_board
    end
    
    !@game_board.bombed? ? (puts "Yay! :)") : (puts "GAME OVER")
    
    @game_board.display_board(true)
    
  end
  
  require 'yaml'
  def load_game
    
  end
  
  def save_game
    File.open('saved_game.yaml','w') do |f|
      f.print @game_board.to_yaml
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
    puts "Please enter the row of your desired tile or save to save and quit:"
    print "==>"
    input = gets.chomp
    
    if input.downcase == "save"
      save_game
      exit
    end
    
    row = Integer(input)
 
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
  
  def apply_action(action, row, col)
    
    if action == FLAGGED_ACTION
      if @game_board.board[row][col].flagged?
        @game_board.board[row][col].flagged = false
      else
        @game_board.board[row][col].flagged = true
      end
    elsif action == REVEAL_ACTION
      tile = @game_board.board[row][col]
      tile.revealed = true
      @game_board.reveal_neighbors(tile)
    end
  end
  
# end game class
end

class Board
  
  attr_reader :board, :height, :width
  attr_writer :bombed
  
  def initialize(width=9, height=9, total_bombs=10)
    @width, @height, @total_bombs = width, height, total_bombs
    build_board
  end
  
  def bombed?
    @bombed
  end
  
  def over?
    # over if tile is bomb and revealed
    bombed? || won?
    # over if all non-bomb tiles are revealed
  end
  
  def won?
    revealed_count == (@width * @height) - @total_bombs
  end
  
  def revealed_count
    counter = 0
    @height.times do |x|
      @width.times do |y|
        tile = @board[x][y]
        counter += 1 if tile.revealed? && !tile.bomb?
      end
    end
    counter
  end
  
  def display_board(with_bombs=false)
    #
    @height.times do |x|
      @width.times do |y|
        print @board[x][y].symbol(with_bombs) + ' '
      end
      print "\n"
    end
  end
  
  def build_board
    @board = Array.new(@height) { Array.new(@width)}
    
    # Initialize with tiles and their coordinates
    @height.times do |x|
      @width.times do |y|
        @board[x][y] = Tile.new([x,y],self)
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

  def reveal_neighbors(tile)
    return if tile.neighbor_bomb_count > 0
    
    neighbor_queue = tile.neighbors
    seen_neighbors = [tile.coords]
    
    until neighbor_queue.empty?
      neighbor = neighbor_queue.shift
      neighbor_tile = @board[neighbor.first][neighbor.last]
      
      unless neighbor_tile.bomb?
        neighbor_tile.revealed = true
        if neighbor_tile.neighbor_bomb_count == 0
          new_neighbors = neighbor_tile.neighbors - seen_neighbors
          neighbor_queue += new_neighbors
        end
      end
      
      seen_neighbors << neighbor
      
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
  attr_writer :bomb, :flagged
  
  def initialize(coords,board)
    @game_board = board
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
  
  def revealed=(status)
    if self.flagged?
      puts "Unflag to reveal this tile"
    elsif self.bomb?
      #raise "You hit a BOMB!"
      @game_board.bombed = true
    else
      @revealed = status
    end
  end
  
  def hidden?
    !(@flagged) && !(@revealed)
  end
  
  def symbol(with_bombs=false)
    return "B" if bomb? if with_bombs
    return "*" if hidden?
    return "F" if flagged?
    @neighbor_bomb_count > 0 ? @neighbor_bomb_count.to_s : "_"
  end
  
end

if $PROGRAM_NAME == __FILE__
  a = Game.new
  a.run
end