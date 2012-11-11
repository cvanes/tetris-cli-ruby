class Tetris
  def initialize(ui)
    @all_shapes = ["I", "J", "L", "O", "S", "Z", "T"]
    @board = Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
    @level = 1
    @lines = 0
    @game_over = false
    @ui = ui
    @ui.show_board(@board)
    @ui.set_score(@lines, @level)
  end

  def new_shape
    @active_shape = eval(@all_shapes[rand(0..6)]).new
    if !can_move_down?
      @game_over = true
    end
    draw_board
  end

  def draw_board
    clear_board_of_active_shapes
    if @active_shape != nil
      add_active_shape_to_board
    end
    @ui.show_board(@board)
    @ui.set_score(@lines, @level)
  end

  def add_active_shape_to_board
    @active_shape.each_cell { |row,column,cell|
      if cell == "x"
        @board[row + @active_shape.row][column + @active_shape.column] = cell
      end
    }
  end

  def mark_active_shape_inactive
    change_appearance_of_active_shape "o"
  end

  def clear_board_of_active_shapes
    change_appearance_of_active_shape "-"
  end

  def change_appearance_of_active_shape(new_char)
    set_board { |cell| cell == "x" ? new_char : cell }
  end

  def set_board
    for row in 0..@board.length - 1
      for column in 0..@board[row].length - 1
        @board[row][column] = yield @board[row][column]
      end
    end
  end  

  def can_rotate?
    true
  end

  def can_move_left?
    if @active_shape.column <= 0
      return false
    end
    can_move_to?(@active_shape.row, @active_shape.column - 1)
  end

  def can_move_right?
    if @active_shape.column + @active_shape.width >= BOARD_COLUMNS
      return false
    end
    can_move_to?(@active_shape.row, @active_shape.column + 1)
  end

  def can_move_down?
    if @active_shape.bottom + 1 >= BOARD_ROWS
      return false
    end
    can_move_to?(@active_shape.row + 1, @active_shape.column)
  end

  def can_move_to?(start_row, start_column)
    @active_shape.each_cell { |row,column,cell|
      if @board[start_row + row][start_column + column] == "o" && cell == "x"
        return false
      end
    }
    true
  end

  def rotate
    if can_rotate?
      if @active_shape.column + @active_shape.height > BOARD_COLUMNS
        @active_shape.column = BOARD_COLUMNS - @active_shape.height
      end
      @active_shape.rotate
      draw_board
    end
  end  

  def left
    if can_move_left?
      @active_shape.left
      draw_board
    end
  end  

  def right
    if can_move_right?
      @active_shape.right
      draw_board
    end
  end

  def down
    if can_move_down?
      @active_shape.down
      delete_complete_lines
      level_up
    else
      mark_active_shape_inactive
      new_shape
    end
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
      sleep_for_level
      @lines += completed_lines
    end
    @board.delete_if { |row| row.uniq == ["="] }
    completed_lines.times { @board.unshift Array.new(BOARD_COLUMNS, "-") }
  end

  def level_up
    if @lines >= 5
      @level = (@lines / 5) + 1
    end
  end

  def start_game
    game_thread = Thread.new {
      new_shape
      draw_board
      sleep_for_level
      loop do
        down  
        draw_board
        sleep_for_level
      end
    }

    Thread.new {
      loop do
        if game_over?
          @ui.display_game_over
          game_thread.kill
          break
        end
        sleep 0.25
      end
    }.join
  end

  def game_over?
    @game_over
  end

  def sleep_for_level
    sleep 1.0 / (@level * 0.5)
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
    @blocks.each_index { |row|
      @blocks[row].each_index { |column|
        yield row, column, @blocks[row][column]
      }
    }
  end

  def height
    @blocks.length
  end

  def width
    size = 0
    @blocks.each { |row|
      if row.length > size
        size = row.length
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

  def left
    @column -= 1
  end  

  def right
    @column += 1
  end

  def down
    @row += 1
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