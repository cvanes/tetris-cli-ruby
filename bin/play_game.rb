#!/usr/bin/env ruby

require_relative '../lib/tetris'
require_relative '../lib/terminal'

BOARD_ROWS = ARGV[0] == nil ? 20 : ARGV[0].to_i
BOARD_COLUMNS = ARGV[1] == nil ? 20 : ARGV[1].to_i
STATUS_LINE = BOARD_ROWS + 2
INFO_COLUMN = BOARD_COLUMNS + 2
SCORE_ROW = 2
LEVEL_ROW = SCORE_ROW + 1
NEXT_PIECE_ROW = LEVEL_ROW + 1

begin
  terminal = Terminal.new
  game = Tetris.new(terminal)
  terminal.game = game
  game.start_game
ensure
  terminal.close
end