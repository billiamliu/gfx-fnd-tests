require 'minitest/autorun'
require_relative 'ans_02_camera'

class TestLineModule < MiniTest::Test

  class Line
    include LineLike

    attr_reader :dx, :dy
    attr_accessor :xo, :yo

    def initialize dx, dy, xo = 0, yo = 0
      @dx, @dy, @xo, @yo = dx, dy, xo, yo
    end
  end

  class Ray
    include LineLike::Ray

    attr_reader :xo, :yo, :rotation

    def initialize xo, yo, rotation
      @xo, @yo, @rotation = xo, yo, rotation
    end
  end


  def setup
    @obj = Object.new
    @obj.extend LineLike
    @pi = Math::PI

    @q1 = [   10,   10 ]
    @q2 = [ - 10,   10 ]
    @q3 = [ - 10, - 10 ]
    @q4 = [   10, - 10 ]
  end
  
  def test_equal
    [
      [1,1], [-1.0001, -1], [1.0001, 1], [-1, -1.0001], [1, 1.0001]
    ].map do |spec|
      # assert @obj.equal?( *spec )
    end

    [
      [1,2], [-1,-2], [2,1], [-2,-1]
    ].map do |spec|
      # assert ! @obj.equal?( *spec )
    end
  end

  def test_rotation
    [ # right, left, up, down
      [ 0, [10,0] ],
      [ @pi, [-10,0] ],
      [ @pi / 2, [0,10] ],
      [ @pi * 1.5, [0,-10] ],
      # Q1..4
      [ @pi / 4 * 1, @q1 ],
      [ @pi / 4 * 3, @q2 ],
      [ @pi / 4 * 5, @q3 ],
      [ @pi / 4 * 7, @q4 ]
    ].map do |spec|
      assert_equal spec[0], Line.new( *spec[1] ).rotation
    end
  end

  def test_slope
    [
      [ 1, @q1 ],
      [ -1, @q2 ],
      [ 1, @q3 ],
      [ -1, @q4 ]
    ].map do |spec|
      # assert_equal spec[0], Line.new( *spec[1] ).slope
    end
  end

  def test_bias
    [
      # line pointing top right
      [ 0, [ *@q1, 3, 3 ] ],
      [ 6, [ *@q1, -3, 3 ] ],
      [ 0, [ *@q1, -3, -3 ] ],
      [ -6, [ *@q1, 3, -3 ] ],
      # line pointing top left
      [ 6, [ *@q2, 3, 3 ] ],
      [ 0, [ *@q2, -3, 3 ] ],
      [ -6, [ *@q2, -3, -3 ] ],
      [ 0, [ *@q2, 3, -3 ] ]
    ].map do |spec|
      # assert_equal spec[0], Line.new( *spec[1] ).bias
    end
  end

  def test_parallel_to
    h_line = Line.new 10, 0
    v_line = Line.new 0, 10
    d_line = Line.new 10, 10

    assert h_line.parallel_to?( h_line )
    assert ! h_line.parallel_to?( v_line )
    assert ! h_line.parallel_to?( d_line )
    assert ! v_line.parallel_to?( d_line )
  end

  def test_intercept_at
    [
    ].map do |spec|
    end
  end

end

