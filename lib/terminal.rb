require 'curses'
include Curses

class Terminal
  attr_accessor :game

  def initialize
    noecho
    init_screen
    stdscr.keypad(true)

    Thread.new {
      loop do
        handle_user_input
      end
    }
  end

  def close
    close_screen
  end  

  def handle_user_input
    case getch
      when Key::UP
        @game.rotate
      when Key::DOWN
        @game.down
      when Key::LEFT
        @game.left
      when Key::RIGHT
        @game.right
    end
  end  

  def show_board(board)
    write(0, 0, board_to_s(board))
  end

  def board_to_s(board)
    game_board = "\n"
    board.each { |row| game_board += row.join + "\n" }
    game_board
  end

  def set_status(text)
    clear_status_line
    write(STATUS_LINE, 0, text)
  end

  def set_active_shapes(active_shape, next_shape)
    write(NEXT_PIECE_ROW, INFO_COLUMN, "Next Piece:")
    i = 2
    next_shape.each_row { |row|
      write(NEXT_PIECE_ROW + i, INFO_COLUMN + 1, row.join.gsub("-", " "))
      i = i+ 1
    }
  end

  def set_score(lines, level)
    write(SCORE_ROW, INFO_COLUMN, "Lines: " + lines.to_s)
    write(LEVEL_ROW, INFO_COLUMN, "Level: " + level.to_s)
  end

  def clear_status_line
    setpos(STATUS_LINE, 0)
    deleteln
  end

  def write(row, column, text)
    setpos(row, column)
    addstr(text);
    refresh
  end

  def display_game_over
    set_status("Game Over!!!\n\nPress any key...")
    block_waiting_for_confirmation
  end

  def block_waiting_for_confirmation
    timeout = -1
    getch
  end
end
