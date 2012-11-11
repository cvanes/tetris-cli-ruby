require 'tetris'

BOARD_ROWS = 2
BOARD_COLUMNS = 2

def empty_board
  Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
end

describe Tetris do
  before(:each) do
    @ui = double("ui")
    @game = Tetris.new(@ui)
  end

  def expect_empty_board
    @ui.should_receive(:show_board).with(empty_board)
    @ui.should_receive(:set_score).with(0, 1)    
  end

  it "#new should create empty board" do
    expect_empty_board
    @game.draw_board
  end
end