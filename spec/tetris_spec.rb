require_relative 'spec_helper'

BOARD_ROWS = 10
BOARD_COLUMNS = 15

def empty_board
  Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
end

def game_board_to_s
  game_board = "\n"
  @board.each { |row| game_board += row.join + "\n" }
  puts game_board
end

describe "Game" do
  before(:each) do
    @ui = double("ui")
    @ui.stub(:show_board) { |board| @board = board }
    @ui.stub(:set_active_shapes) { |active_shape,next_shape| @active_shape, @next_shape = active_shape, next_shape }
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

  context "user input" do
    before(:each) do
      @game.new_shape
      @top = @active_shape.row
      @left = @active_shape.column
      @height = @active_shape.height
      @width = @active_shape.width
    end

    describe "down" do
      it "should move active shape down one row" do
        @game.down
        @active_shape.row.should == @top + 1
      end

      it "should mark shape as inactive when it hits the bottom" do
        shape_being_moved_down = @active_shape
        for i in 0..BOARD_ROWS - shape_being_moved_down.height
          @game.down
        end
        shape_being_moved_down.active?.should be false
      end

      it "should create new shape at top when previous hits bottom" do
        for i in 0..BOARD_ROWS - @active_shape.height
          @game.down
        end
        @active_shape.row.should == 0
      end      
    end

    describe "right" do
      it "should move active shape right one column" do
        @game.right
        @active_shape.column.should == @left + 1
      end

      it "should not be able to move right past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.right
        end
        @active_shape.column.should == BOARD_COLUMNS - @active_shape.width
      end
    end    

    describe "left" do
      it "should move active shape left one column" do
        @game.left
        @active_shape.column.should == @left - 1
      end

      it "should not be able to move left past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.left
        end
        @active_shape.column.should == 0
      end      
    end   

    # BUG: this will fail as for some reason it takes two calls to rotate
    describe "rotate" do
      it "should rotate active shape which isn't blocked in any dimension" do
        @game.rotate
        @active_shape.height.should == @width
        @active_shape.width.should == @height
      end
    end      
  end
end