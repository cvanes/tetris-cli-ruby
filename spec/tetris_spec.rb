require 'tetris'

BOARD_ROWS = 10
BOARD_COLUMNS = 15

def empty_board
  Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
end

def each_active_cell
  @board.each_index { |row|
    @board[row].each_index { |column|
      if @board[row][column] == "x"
        yield row, column
      end
    }
  }
end

def each_active_shape_cell
  @active_shape.each_index { |row|
    @active_shape[row].each_index { |column|
      yield row, column
    }
  }  
end

def active_shape_top_left
  top, left = BOARD_ROWS, BOARD_COLUMNS
  each_active_cell { |row,column|
    if row < top
      top = row
    end
    if column < left
      left = column
    end
  }
  return top, left
end

def active_shape_bottom_right
  bottom, right = 0, 0
  each_active_cell { |row,column|
    if row > bottom
      bottom = row
    end
    if column > right
      right = column
    end
  }
  return bottom, right
end

def active_shape_height
  top, left = active_shape_top_left
  bottom, right = active_shape_bottom_right
  bottom - top + 1
end

def active_shape_width
  top, left = active_shape_top_left
  bottom, right = active_shape_bottom_right
  right - left + 1
end

def active_shape_from_board
  @active_shape = Array.new(active_shape_height) { Array.new(active_shape_width, "-") }
  top, left = active_shape_top_left
  each_active_shape_cell { |row,column|
    if @board[row + top][column + left] == "x"
      @active_shape[row][column] = @board[row + top][column + left]
    end
  }
  @active_shape
end

def display(shape)
  output = "\n"
  shape.each { |row| output += row.join + "\n" }
  output
  puts output
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

      it "should mark shape as inactive when it hits the bottom" do
        active_shape = active_shape_from_board
        height = active_shape_height
        for i in 0..BOARD_ROWS - height
          @game.down
        end
        start_row = BOARD_ROWS - height
        start_column = @old_column
        each_active_shape_cell { |row,column|
          if active_shape[row][column] == "x"
            @board[start_row + row][start_column + column].should == "o"
          end
        }
      end

      it "should create new shape at top when previous hits bottom" do
        for i in 0..BOARD_ROWS - active_shape_height
          @game.down
        end
        row, column = active_shape_top_left
        row.should == 0
      end      
    end

    describe "#right" do
      it "should move active piece right one column" do
        @game.right
        row, column = active_shape_top_left
        column.should == @old_column + 1
      end

      it "should not be able to move right past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.right
        end
        row, column = active_shape_bottom_right
        column.should == BOARD_COLUMNS - 1
      end
    end    

    describe "#left" do
      it "should move active piece left one column" do
        @game.left
        row, column = active_shape_top_left
        column.should == @old_column - 1
      end

      it "should not be able to move left past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.left
        end
        row, column = active_shape_top_left
        column.should == 0
      end      
    end     
  end
end