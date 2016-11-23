require "matrix"
require "./thingy.rb"

class Matrix
  def rotate x, y
    # I can't find a neat matrix-math solution for
    # this, so let's do it with regular 'ol `map`.
    Matrix[ *self.to_a.rotate(y).map {|row| row.rotate x} ]
  end

  # Pad or shrink a matrix
  def take x, y
    Matrix.build(y, x){|i, j| if self[i, j].nil? then 0 else self[i, j] end }
  end

  # Bitwise operations on boolean matrices
  def & other
    Matrix.Raise ErrDimensionMismatch unless
      self.row_count == other.row_count and
      self.column_count == other.column_count

    Matrix.build(self.row_count){|i, j| self[i, j] & other[i, j] }
  end

  def | other
    Matrix.Raise ErrDimensionMismatch unless
      self.row_count == other.row_count and
      self.column_count == other.column_count

    Matrix.build(self.row_count){|i, j| self[i, j] | other[i, j] }
  end
end

class LitoGol
  AROUND = [-1, 0, 1].product([-1, 0, 1])

  attr_accessor :matrix

  def initialize width
    self.matrix = Matrix[[1, 1, 1],
                         [0, 0, 1],
                         [1, 1, 1]].take(width, width).rotate(-(width/2), -(width/2))
  end

  def sum l
    l.reduce :+
  end

  def twos grid
    grid.map{|i| if i == 2 then 1 else 0 end}
  end

  def threes grid
    grid.map{|i| if i == 3 then 1 else 0 end}
  end

  def neighbors grid
    sum(AROUND.map{|x, y| grid.rotate x, y } ) - grid
  end

  def life grid
    ((twos neighbors grid) & grid) | (threes neighbors grid)
  end

  def update
    self.matrix = life matrix
  end

  def each
    matrix.to_a.each_with_index do |row, y|
      row.each_with_index do |c, x|
        yield c, x, y
      end
    end
  end
end

class LitoGolThingy < Thingy
  attr_accessor :gol

  SIZE, WIDTH = 10, 64

  def initialize
    super 640, 640, 16, "Conway's Game of Life"

    self.gol = LitoGol.new WIDTH
  end

  def draw n
    blank

    gol.each do |c, x, y|
      if c == 1 then
        ellipse x*SIZE, y*SIZE, (SIZE-1)/2, (SIZE-1)/2, :white
        text n.to_s, 10, 10, :green
      end
    end
  end

  def update n
    self.gol.update
  end
end

LitoGolThingy.new.run
