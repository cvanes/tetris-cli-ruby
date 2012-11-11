require 'tetris'

BOARD_ROWS = 10
BOARD_COLUMNS = 15

def empty_board
  Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
end

def active_shape_top_left
  @board.each_index { |row|
    @board[row].each_index { |column|
      if @board[row][column] == "x"
        return row, column
      end
    }
  }
end

describe Tetris do
  before(:each) do
    @ui = double("ui")
    @ui.stub(:show_board) { |board| @board = board }
    @ui.stub(:set_score) { |lines,level| @lines, @level = lines, level }    
    @game = Tetris.new(@ui)
  end

  describe "#new" do
    it "should create empty board" do
      @board.should == empty_board
    end

    it "should start on level one" do
      @level.should == 1
    end

    it "should start with zero lines" do
      @lines.should == 0
    end    
  end  

  context "moving shape" do
    before(:each) do
      @game.new_shape
      @old_row, @old_column = active_shape_top_left
    end

    describe "#down" do
      it "should move active piece down one row" do
        @game.down
        row, column = active_shape_top_left
        row.should == @old_row + 1
      end
    end

    describe "#right" do
      it "should move active piece right one column" do
        @game.right
        row, column = active_shape_top_left
        column.should == @old_column + 1
      end

      it "should not be able to move right past edge of board" do
        for i in 0..BOARD_COLUMNS
          @game.right
        end
        row, column = active_shape_top_left
        column.should be < BOARD_COLUMNS
      end
    end    

    describe "#left" do
      it "should move active piece left one column" do
        @game.left
        row, column = active_shape_top_left
        column.should == @old_column - 1
      end

      it "should not be able to move left past edge of board" do
        for i in 0..BOARD_COLUMNS
          @game.left
        end
        row, column = active_shape_top_left
        column.should be >= 0
      end      
    end     
  end
end