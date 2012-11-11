require 'curses'
include Curses

class TerminalOutput
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

  def set_score(lines, level)
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

  def display_game_over
    set_status("Game Over!!!\n\nPress any key...")
    block_waiting_for_confirmation
  end

  def block_waiting_for_confirmation
    Curses.timeout = -1
    Curses.getch
  end
end

class TerminalInput
  def initialize(game)
    @game = game
    Thread.new {
      loop do
        handle_user_input
      end
    }
  end

  def handle_user_input
    case Curses.getch
      when Curses::Key::UP
        @game.rotate
      when Curses::Key::DOWN
        @game.down
      when Curses::Key::LEFT
        @game.left
      when Curses::Key::RIGHT
        @game.right
    end
  end
end 