require 'curses'
include Curses

BOARD_ROWS = ARGV[0] == nil ? 20 : ARGV[0].to_i
BOARD_COLUMNS = ARGV[1] == nil ? 30 : ARGV[1].to_i
STATUS_LINE = BOARD_ROWS + 2
SCORE_ROW = 2
SCORE_COLUMN = BOARD_COLUMNS + 2

def write_top_left(text)
  write(0, 0, text)
end

def write_status(text)
  clear_status_line
  write(STATUS_LINE, 0, text)
end

def write_score(lines, level)
  write(SCORE_ROW, SCORE_COLUMN, "Lines: " + lines.to_s)
  write(SCORE_ROW + 1, SCORE_COLUMN, "Level: " + level.to_s)
end

def clear_status_line
  Curses.setpos(STATUS_LINE, 0)
  Curses.deleteln
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

  def can_move_left?
    if @active_piece.column <= 0
      return false
    end
    can_move?(@active_piece.row, @active_piece.column - 1)
  end

  def left
    if can_move_left?
      @active_piece.column -= 1
      draw_board
    end
  end

  def can_move_right?
    if @active_piece.column + @active_piece.width >= BOARD_COLUMNS
      return false
    end
    can_move?(@active_piece.row, @active_piece.column + 1)
  end

  def right
    if can_move_right?
      @active_piece.column += 1
      draw_board
    end
  end

  def can_move_down?
    if @active_piece.bottom >= BOARD_ROWS
      return false
    end
    can_move?(@active_piece.row, @active_piece.column)
  end

  def can_move?(start_row, start_column)
    @active_piece.each_cell { |row,column|
      if @board[start_row + row][start_column + column] == "o" && @active_piece.blocks[row][column] == "x"
        return false
      end
    }
    true
  end

  def down
    @active_piece.row += 1
    if !can_move_down?
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
    if completed_lines > 0
      draw_board
      sleep_based_on_level
      @lines += completed_lines
      if @lines > 5
        @level = @lines / 5
      end
    end
    @board.delete_if { |row| row.uniq == ["="] }
    completed_lines.times { @board.unshift Array.new(BOARD_COLUMNS, "-") }
  end

  def game_over?
    !can_move_down? #&& !can_move_left && !can_move_right
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
      sleep_based_on_level
      loop do
        down
        sleep_based_on_level
        write_status(can_move_down?.to_s + "\n" + game_over?.to_s)
        if game_over?
          write_status("Game Over!!!\n\nPress any key...")
          block_waiting_for_key_press
          break
        end
      end
    }.join
  end

  def sleep_based_on_level
    sleep 1.0 / (@level * 0.5)
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
        left
      when Curses::Key::RIGHT
        right
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

  Tetris.new.start_game
ensure
  Curses.close_screen
end