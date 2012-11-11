require 'tetris'

BOARD_ROWS = 10
BOARD_COLUMNS = 15

def empty_board
  Array.new(BOARD_ROWS) {Array.new(BOARD_COLUMNS, "-")}
end

def each_active_cell_on_board
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

def active_shape_top
  top = BOARD_ROWS
  each_active_cell_on_board { |row,column|
    if row < top
      top = row
    end
  }
  top
end

def active_shape_left
  left = BOARD_COLUMNS
  each_active_cell_on_board { |row,column|
    if column < left
      left = column
    end
  }
  left
end

def active_shape_bottom
  bottom = 0
  each_active_cell_on_board { |row,column|
    if row > bottom
      bottom = row
    end
  }
  bottom
end

def active_shape_right
  right = 0
  each_active_cell_on_board { |row,column|
    if column > right
      right = column
    end
  }
  right
end

def active_shape_height
  top = active_shape_top
  bottom = active_shape_bottom
  bottom - top + 1
end

def active_shape_width
  left = active_shape_left
  right = active_shape_right
  right - left + 1
end

def active_shape_from_board
  @active_shape = Array.new(active_shape_height) { Array.new(active_shape_width, "-") }
  top = active_shape_left
  left = active_shape_left
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
      @top = active_shape_top
      @left = active_shape_left
    end

    describe "#down" do
      it "should move active piece down one row" do
        @game.down
        active_shape_top.should == @top + 1
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
        active_shape_top.should == 0
      end      
    end

    describe "#right" do
      it "should move active piece right one column" do
        @game.right
        active_shape_left.should == @left + 1
      end

      it "should not be able to move right past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.right
        end
        active_shape_left.should == BOARD_COLUMNS - active_shape_width
      end
    end    

    describe "#left" do
      it "should move active piece left one column" do
        @game.left
        active_shape_left.should == @left - 1
      end

      it "should not be able to move left past edge of board" do
        for i in 1..BOARD_COLUMNS
          @game.left
        end
        active_shape_left.should == 0
      end      
    end     
  end
end