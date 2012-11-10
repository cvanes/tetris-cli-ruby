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
    draw
  end

  def draw
    clear_board_of_active_pieces
    @active_piece.each_cell { |row,column|
      if @active_piece.blocks[row][column] == "x"
        @board[row + @active_piece.row][column + @active_piece.column] = @active_piece.blocks[row][column]
      end
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
    each_board_cell { |row,column| if @board[row][column] == "x"; @board[row][column] = new_char end }
  end

  def rotate
    @active_piece.rotate
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
    @active_piece.row += 1
    if blocked?
      mark_active_piece_inactive
      newPiece
    end
    delete_complete_lines
    draw
  end

  def delete_complete_lines
    for i in 0..@board.length - 1
      line_complete = true
      for j in 0..@board[i].length - 1
        line_complete &= @board[i][j] == "o"
      end
      if line_complete
        @board.delete_at i
        sleep 1
      end
    end
  end

  def game_over?
    blocked? && @active_piece.row == 0
  end

  def blocked?
    if @active_piece.bottom >= BOARD_ROWS
      return true
    end
    @active_piece.each_cell { |row,column|
      if @board[@active_piece.row + row][@active_piece.column + column] == "o" && @active_piece.blocks[row][column] == "x"
        return true
      end
    }
    false
  end

  def each_board_cell
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
      sleep 1 / @level
      loop do
        down
        sleep 1 / @level
        if game_over?
          write(STATUS_LINE, 0, "Game Over!!!\n\nPress any key...")
          block_waiting_for_key_press
          break
        end
      end
    }.join
  end

  def block_waiting_for_key_press
    Curses.timeout = -1
    Curses.getch
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

  def can_move_left?
    @column > 0
  end

  def can_move_right?
    @column + width < BOARD_COLUMNS
  end

  def rotate
    temp = @all_block_positions.shift
    @all_block_positions.push(temp)
    @blocks = temp
  end
end

class I < Tetrimino
  def initialize
    super([[%w[x x x x]], [["x"],["x"],["x"],["x"]]])
  end
end

class J < Tetrimino
  def initialize
    super([[%w[- x], %w[- x], %w[x x]], [%w[x - -], %w[x x x]], [%w[x x], %w[x -], %w[x -]], [%w[x x x], %w[- - x]]])
  end
end

class L < Tetrimino
  def initialize
    super([[%w[x -], %w[x -], %w[x x]], [%w[x x x], %w[x - -]], [%w[x x], %w[- x], %w[- x]], [%w[- - x], %w[x x x]]])
  end
end

class O < Tetrimino
  def initialize
    super([[%w[x x], %w[x x]]])
  end
end

class S < Tetrimino
  def initialize
    super([[%w[- x x], %w[x x -]], [%w[x -], %w[x x], %w[- x]]])
  end
end

class Z < Tetrimino
  def initialize
    super([[%w[x x -], %w[- x x]], [%w[- x], %w[x x], %w[x -]]])
  end
end

class T < Tetrimino
  def initialize
    super([[%w[x x x], %w[- x -]], [%w[- x], %w[x x], %w[- x]],[%w[- x -], %w[x x x]], [%w[x -], %w[x x], %w[x -]]])
  end
end

Curses.noecho
Curses.init_screen
Curses.stdscr.keypad(true)

Tetris.new.start_game

Curses.close_screen
