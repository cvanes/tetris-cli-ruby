require 'curses'

BOARD_ROWS = 20
BOARD_COLUMNS = 30
STATUS_LINE = 22

def write(row = 0, column = 0, text)
  Curses.setpos(row, column)
  Curses.addstr(text);
  Curses.refresh
end

class Tetris
  def initialize
    @pieces = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
    @level = 1
  end

  def newPiece
    @active_piece = eval(@pieces[rand(0..6)]).new
  end

  def draw
    clear_board_of_active_pieces
    @active_piece.each_cell { |row,column|
      @board[row + @active_piece.row][column + @active_piece.column] = @active_piece.blocks[row][column]
    }
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
    update_active_piece_display "o"
  end

  def clear_board_of_active_pieces
    update_active_piece_display "-"
  end

  def update_active_piece_display(new_char)
    iterate_over_board { |row,column| if @board[row][column] == "x"; @board[row][column] = new_char end }
  end

  def rotate
    #@active_piece.rotate
    draw
  end

  def left
    if @active_piece.can_move_left?
      @active_piece.column -= 1
      draw
    end
  end

  def right
    if @active_piece.can_move_right?
      @active_piece.column += 1
      draw
    end
  end

  def down
    if @active_piece.hit_bottom?
      mark_active_piece_inactive
      newPiece
      draw
    else
      draw
      @active_piece.row += 1
      if next_move_blocked_vertically?
        mark_active_piece_inactive
        newPiece
      end
    end
  end

  def game_over?
    next_move_blocked_vertically? && @active_piece.row == 0
  end

  def next_move_blocked_vertically?
    if @active_piece.bottom >= BOARD_ROWS
      return true
    end
    for i in 0..@active_piece.blocks[@active_piece.height - 1].length
      if @board[@active_piece.bottom][i + @active_piece.column] == "o" && @active_piece.blocks[@active_piece.height - 1][i] == "x"
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
          write(STATUS_LINE, 0, "Game Over!!!\n\nPress any key...")
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

  def initialize(blocks)
    @all_block_positions = blocks
    @blocks = @all_block_positions.first
    @column = (BOARD_COLUMNS - width) / 2 - 1
    @row = 0
  end

  def each_cell
    for i in 0..@blocks.length - 1
      for j in 0..@blocks[i].length - 1
        yield i, j
      end
    end
  end

  def height
    @blocks.length
  end

  def width
    size = 0
    @blocks.each { |column|
      if column.length > size
        size = column.length
      end
    }
    return size
  end

  def bottom
    @row + height - 1
  end

  def hit_bottom?
    bottom >= BOARD_ROWS
  end

  def can_move_left?
    @column > 0
  end

  def can_move_right?
    @column + width < BOARD_COLUMNS
  end

  def rotate
    write(STATUS_LINE, 0 , @all_block_positions)
    @all_block_positions.rotate
    write(STATUS_LINE, 0 , @all_block_positions)
    @blocks = @all_block_positions.first
    write(STATUS_LINE, 0 , @blocks)
  end
end

class I < Tetrimino
  def initialize
    super([[["x", "x", "x", "x"]], [["x"],["x"],["x"],["x"]]])
  end
end

class J < Tetrimino
  def initialize
    super([[["-", "x"], ["-", "x"], ["x", "x"]]])
  end
end

class L < Tetrimino
  def initialize
    super([[["x", "-"], ["x", "-"], ["x", "x"]]])
  end
end

class O < Tetrimino
  def initialize
    super([[["x", "x"], [ "x", "x"]]])
  end
end

class S < Tetrimino
  def initialize
    super([[["-", "x", "x"], ["x", "x", "-"]]])
  end
end

class Z < Tetrimino
  def initialize
    super([[["x", "x", "-"], ["-", "x", "x"]]])
  end
end

class T < Tetrimino
  def initialize
    super([[["x", "x", "x"], ["-", "x", "-"]]])
  end
end

Curses.noecho
Curses.init_screen
Curses.stdscr.keypad(true)

Tetris.new.start_game

Curses.close_screen
