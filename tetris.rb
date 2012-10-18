class Tetris
  def initialize
    @board = Array.new(10)
    @board.each do |row|
      row = Array.new(15)
    end
  end
end

# pieces I, J, L, O, S, T, Z

class I < Tetrimino
  def fits?()

  end
end

class Tetrimino
  def rotate()

  end

  def moveLeft()

  end

  def moveRight()

  end
end