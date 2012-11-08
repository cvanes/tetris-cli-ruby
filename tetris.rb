$Board_x_size = 10
$Board_y_size = 15

class Tetris
  def initialize
    @@board = Array.new($Board_x_size)
    @@board.each do |row|
      row = Array.new($Board_y_size)
    end
  end

  def newPiece
    #I.new
    # use send and a hash to pick new piece?
  end

  def draw

  end
end

class Tetrimino
  def intialize(blocks)
    i = 0
    j = $Board_y_size
    while i < blocks.length
      while j < i.length
        Tetris.board[i][j] = blocks[i][j]
        j+=1
      end
      i+=1
    end
  end
end

# pieces I, J, L, O, S, Z, T

class I < Tetrimino
  def initialize()
    super([['x', 'x', 'x', 'x']])
  end
end

class J < Tetrimino
  def initialize()
    super([[nil, nil, 'x'], [nil, nil, 'x'], [nil, 'x', 'x']])
  end
end

class L < Tetrimino
  def initialize()
    super([['x', nil, nil], ['x', nil, nil], ['x', 'x', nil]])
  end
end

class O < Tetrimino
  def initialize()
    super([['x', 'x'], [ 'x', 'x']])
  end
end

class S < Tetrimino
  def initialize()
    super([[nil, 'x', 'x'], ['x', 'x', nil]])
  end
end

class Z < Tetrimino
  def initialize()
    super([['x', 'x', nil], [nil, 'x', 'x']])
  end
end

class T < Tetrimino
  def initialize()
    super([['x', 'x', 'x'], [nil, 'x', nil]])
  end
end


#---***----
#----*-----
#
#
#
#
#
#
#
#
