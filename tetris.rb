$board_x_size = 10
$board_y_size = 15

class Tetris
  def initialize
    @pieces = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new($board_x_size) {Array.new($board_y_size) {"-"}}
    @level = 1
  end

  def newPiece
    @active_piece = eval(@pieces[rand(0..6)]).new
  end

  def draw
    puts "\n"
    @board.each do |row|
      row.each do |column|
        print column
      end
      print "\n"
    end
  end

  def clear_board_of_active_pieces
    for i in 0..@board.length - 1
      for j in 0..@board[i].length - 1
        if @board[i][j] = "*"
          @board[i][j] = "-"
        end
      end
    end
  end

  def move_active_piece_one_space_in_y_dimension
    # move a row down
    @active_piece.y += 1

    y = @active_piece.y
    if y + @active_piece.blocks.length > $board_y_size

    else
      # move to new position
      for i in 0..@active_piece.blocks.length - 1
        for j in 0..@active_piece.blocks[i].length - 1
          @board[i + y][j] = @active_piece.blocks[i][j]
        end
      end
    end
  end

  def move_active_piece
    clear_board_of_active_pieces
    move_active_piece_one_space_in_y_dimension
    draw
  end

  def start_game
    newPiece
    loop do
      move_active_piece
      sleep 1 / @level
    end
  end
end

class Tetrimino
  attr_accessor :blocks
  attr_accessor :x, :y

  def initialize
    @x = -1
    @y = -1
  end
end

# pieces I, J, L, O, S, Z, T

class I < Tetrimino
  def initialize()
    @blocks = [["x", "x", "x", "x"]]
    super()
  end
end

class J < Tetrimino
  def initialize()
    @blocks = [["-", "x"], ["-", "x"], ["x", "x"]]
    super()
  end
end

class L < Tetrimino
  def initialize()
    @blocks = [["x", "-"], ["x", "-"], ["x", "x"]]
    super()
  end
end

class O < Tetrimino
  def initialize()
    @blocks = [["x", "x"], [ "x", "x"]]
    super()
  end
end

class S < Tetrimino
  def initialize()
    @blocks = [["-", "x", "x"], ["x", "x", "-"]]
    super()
  end
end

class Z < Tetrimino
  def initialize()
    @blocks = [["x", "x", "-"], ["-", "x", "x"]]
    super()
  end
end

class T < Tetrimino
  def initialize()
    @blocks = [["x", "x", "x"], ["-", "x", "-"]]
    super()
  end
end

Tetris.new.start_game
