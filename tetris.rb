$board_x_size = 10
$board_y_size = 15

class Tetris
  def initialize
    @pieces = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new($board_x_size) {Array.new($board_y_size, "-")}
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

  def clear_board_of_active_pieces(newCharacter)
    iterate_over_board { |row,column| if @board[row][column] == "x"; @board[row][column] = newCharacter end }
  end

  def move_active_piece_one_space_in_y_dimension
    @active_piece.row += 1

    active_piece_row = @active_piece.row
    if @active_piece.hit_bottom?
      clear_board_of_active_pieces "o"
      newPiece
    else
      clear_board_of_active_pieces "-"
      # move to new position
      iterate_over_active_piece { |row,column| @board[row + active_piece_row][column] = @active_piece.blocks[row][column] }
      if next_move_blocked_vertically?
        clear_board_of_active_pieces "o"
        newPiece
      end
    end
  end

  def game_over?
    next_move_blocked_vertically? && @active_piece.row <= 0
  end

  def next_move_blocked_vertically?
    if @active_piece.bottom >= $board_x_size
      return true
    end
    for i in 0..@active_piece.blocks[@active_piece.height - 1].length
      if @board[@active_piece.bottom][i] == "o" && @active_piece.blocks[@active_piece.height - 1][i] == "x"
        return true
      end
    end
    false
  end

  def move_active_piece
    move_active_piece_one_space_in_y_dimension
    draw
  end

  def iterate_over_board
    for i in 0..@board.length - 1
      for j in 0..@board[i].length - 1
        yield i, j
      end
    end
  end

  def iterate_over_active_piece
    for i in 0..@active_piece.blocks.length - 1
      for j in 0..@active_piece.blocks[i].length - 1
        yield i, j
      end
    end
  end

  def start_game
    newPiece
    loop do
      move_active_piece
      sleep 1 / @level
      if game_over?
        puts "Game Over!!!"
        break
      end
    end
  end
end

class Tetrimino
  attr_accessor :blocks
  attr_accessor :row, :column

  def initialize
    @column = -1
    @row = -1
  end

  def height
    @blocks.length
  end

  def bottom
    @row + height
  end

  def hit_bottom?
    @row + @blocks.length > $board_x_size
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
