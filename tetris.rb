require 'curses'

BOARD_X_SIZE = 20
BOARD_Y_SIZE = 30
STATUS_COLUMN = 22

def write(row = 0, column = 0, text)
  Curses.setpos(row, column)
  Curses.addstr(text);
  Curses.refresh
end

class Tetris
  def initialize
    @pieces = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new(BOARD_X_SIZE) {Array.new(BOARD_Y_SIZE, "-")}
    @level = 1
  end

  def newPiece
    @active_piece = eval(@pieces[rand(0..6)]).new
  end

  def draw
    game_board = "\n"
    @board.each do |row|
      row.each do |column|
        game_board += column
      end
      game_board += "\n"
    end
    write(game_board)
  end

  def mark_active_piece_inactive
    clear_board_of_active_pieces "o"
  end

  def clear_board_of_active_pieces(newCharacter)
    iterate_over_board { |row,column| if @board[row][column] == "x"; @board[row][column] = newCharacter end }
  end

  def rotate

  end

  def left

  end

  def right

  end

  def down
    if @active_piece.hit_bottom?
      mark_active_piece_inactive
      newPiece
    else
      clear_board_of_active_pieces "-"
      # move to new position
      iterate_over_active_piece { |row,column| @board[row + @active_piece.row][column] = @active_piece.blocks[row][column] }
      @active_piece.row += 1
      if next_move_blocked_vertically?
        mark_active_piece_inactive
        newPiece
      end
    end
    draw
  end

  def game_over?
    next_move_blocked_vertically? && @active_piece.row == 0
  end

  def next_move_blocked_vertically?
    if @active_piece.bottom >= BOARD_X_SIZE
      return true
    end
    for i in 0..@active_piece.blocks[@active_piece.height - 1].length
      if @board[@active_piece.bottom][i] == "o" && @active_piece.blocks[@active_piece.height - 1][i] == "x"
        return true
      end
    end
    false
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
    Thread.new {
      loop do
        handle_user_input
      end
    }

    Thread.new {
      newPiece
      loop do
        down
        sleep 1 / @level
        if game_over?
          write(STATUS_COLUMN, 0, "Game Over!!!\n\nPress any key...")
          Curses.timeout = -1
          Curses.getch
          break
        end
      end
    }.join
  end

  def handle_user_input
    case Curses.getch
      when Curses::Key::UP
        rotate
      when Curses::Key::DOWN
        down
      when Curses::Key::LEFT
        left
      when Curses::Key::RIGHT
        right
    end
  end
end

class Tetrimino
  attr_accessor :blocks
  attr_accessor :row, :column

  def initialize
    @column = 0
    @row = 0
  end

  def height
    @blocks.length
  end

  def bottom
    @row + height - 1
  end

  def hit_bottom?
    bottom >= BOARD_X_SIZE
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

Curses.noecho
Curses.init_screen
Curses.stdscr.keypad(true)

Tetris.new.start_game

Curses.close_screen
