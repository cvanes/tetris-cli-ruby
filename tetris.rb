require 'curses'
include Curses

BOARD_ROWS = 15
BOARD_COLUMNS = 10
STATUS_LINE = BOARD_ROWS + 2
SCORE_ROW = 2
SCORE_COLUMN = BOARD_COLUMNS + 2

def write_top_left(text)
  write(0, 0, text)
end

def write_status(text)
  write(STATUS_LINE, 0, text)
end

def write_score(lines, level)
  write(SCORE_ROW, SCORE_COLUMN, "Lines: " + lines.to_s)
  write(SCORE_ROW + 1, SCORE_COLUMN, "Level: " + level.to_s)
end

def write(row, column, text)
  Curses.setpos(row, column)
  Curses.addstr(text);
  Curses.refresh
end

class Tetris
  def initialize
    @all_shapes = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
    @level = 1
    @lines = 0
  end

  def newPiece
    @active_piece = eval(@all_shapes[rand(0..6)]).new
    draw_board
  end

  def draw_board
    Curses.clear
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
    write_top_left(game_board)
    write_score(@lines, @level)
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

  def down
    @active_piece.row += 1
    if blocked?
      mark_active_piece_inactive
      newPiece
    end
    delete_complete_lines
    draw_board
  end

  def delete_complete_lines
    completed_lines = 0
    @board.each_index { |i|
      if @board[i].uniq == ["o"]
        @board[i] = Array.new(BOARD_COLUMNS, "=")
        completed_lines += 1
      end
    }
    @lines += completed_lines
    if completed_lines > 0
      draw_board
      sleep 1 / @level
    end
    @board.delete_if { |row| row.uniq == ["="] }
    completed_lines.times { @board.unshift Array.new(BOARD_COLUMNS, "-") }
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
          write_status("Game Over!!!\n\nPress any key...")
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
        @active_piece.rotate
        draw_board
      when Curses::Key::DOWN
        down
      when Curses::Key::LEFT
        @active_piece.left
        draw_board
      when Curses::Key::RIGHT
        @active_piece.right
        draw_board
    end
  end
end

class Tetrimino
  attr_accessor :blocks
  attr_accessor :row, :column

  def initialize(all_rotations)
    @all_rotations = all_rotations
    @blocks = @all_rotations.first
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

  def left
    if can_move_left?
      @column -= 1
    end
  end

  def can_move_right?
    @column + width < BOARD_COLUMNS
  end

  def right
    if can_move_right?
      @column += 1
    end
  end

  def rotate
    @blocks = @all_rotations.shift
    @all_rotations.push(@blocks)
  end
end

class I < Tetrimino
  def initialize
    super([[%w[x x x x]],
           [%w[x],%w[x],%w[x],%w[x]]])
  end
end

class J < Tetrimino
  def initialize
    super([[%w[- x], %w[- x], %w[x x]],
           [%w[x - -], %w[x x x]],
           [%w[x x], %w[x -], %w[x -]],
           [%w[x x x], %w[- - x]]])
  end
end

class L < Tetrimino
  def initialize
    super([[%w[x -], %w[x -], %w[x x]],
           [%w[x x x], %w[x - -]],
           [%w[x x], %w[- x], %w[- x]],
           [%w[- - x], %w[x x x]]])
  end
end

class O < Tetrimino
  def initialize
    super([[%w[x x], %w[x x]]])
  end
end

class S < Tetrimino
  def initialize
    super([[%w[- x x], %w[x x -]],
           [%w[x -], %w[x x], %w[- x]]])
  end
end

class Z < Tetrimino
  def initialize
    super([[%w[x x -], %w[- x x]],
           [%w[- x], %w[x x], %w[x -]]])
  end
end

class T < Tetrimino
  def initialize
    super([[%w[x x x], %w[- x -]],
           [%w[- x], %w[x x], %w[- x]],
           [%w[- x -], %w[x x x]],
           [%w[x -], %w[x x], %w[x -]]])
  end
end

begin
  Curses.noecho
  Curses.init_screen
  Curses.stdscr.keypad(true)
  #Curses.start_color
  #Curses.init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_BLACK)
  #Curses.attron(color_pair(COLOR_BLUE)|A_BLINK) {
  #  Curses.setpos(STATUS_LINE, 0)
  #  Curses.addstr("This is blue!!!");
  #  Curses.refresh
  #}

  Tetris.new.start_game
ensure
  Curses.close_screen
end