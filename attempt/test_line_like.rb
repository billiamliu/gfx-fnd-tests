require 'minitest/autorun'
require_relative 'line_like'

class TestLineLike < MiniTest::Test

  Line = LineLike::Example::Line
  Ray = LineLike::Example::Ray

  def setup
    @pi = Math::PI

    @q1 = [   10,   10 ]
    @q2 = [ - 10,   10 ]
    @q3 = [ - 10, - 10 ]
    @q4 = [   10, - 10 ]

    segment = @pi / 4
    @r1 = segment
    @r2 = segment * 3
    @r3 = segment * 5
    @r4 = segment * 7
  end
  
  def test_equal
    [
      [1,1], [-1.0001, -1], [1.0001, 1], [-1, -1.0001], [1, 1.0001]
    ].map do |spec|
      assert LineLike.equal?( *spec )
    end

    [
      [1,2], [-1,-2], [2,1], [-2,-1]
    ].map do |spec|
      assert ! LineLike.equal?( *spec )
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
      [ -1, @q4 ],
      [ 0, [10, 0] ],
      [ nil, [0, 10] ],
      [ 0, [-10, 0] ],
      [ nil, [0, -10] ]
    ].map do |spec|
      assert_equal spec[0], Line.new( *spec[1] ).slope
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
      assert_equal spec[0], Line.new( *spec[1] ).bias
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
      [ nil, [ *@q1, 0 ], [ *@q1, 3 ] ],
      [ [0,0], [ *@q1 ], [ *@q2 ] ],
      [ [1,1], [ *@q1 ], [ *@q2, 0, 2 ] ],
      [ [0.5,0.5], [ *@q1 ], [ *@q2, 0, 1 ] ],
      [ [-1,-1], [ *@q3 ], [ *@q4, 0, -2 ] ],
      [ [0,3], [0, 10], [3, 0, 0, 3] ], # vertical intercept horizontal
      [ [3,0], [10, 0], [0, 3, 3, -1] ] # horizontal intercept vertical
    ].map do |spec|
      assert_equal spec[0],
        Line.new( *spec[1] ).intercept_at( Line.new( *spec[2] ) )
    end
  end

  def test_exist_at
    [ # testing line segments
      [ true, @q1, [1,1] ],
      [ true, @q2, [-1,1] ],
      [ true, @q3, [-1,-1] ],
      [ true, @q4, [1,-1] ],

      [ false, @q1, [-1,-1] ],
      [ false, @q2, [1,-1] ],
      [ false, @q3, [1,1] ],
      [ false, @q4, [-1,1] ],
      # add horizontal and verticals
      [ true, [10, 0], [1, 0] ],
      [ false, [10, 0], [11, 0] ],
      [ false, [10, 0], [-1, 0] ],
      [ true, [0, -10], [0, -3] ],
      [ false, [0, -10], [0, 1] ],
      [ false, [0, -10], [0, -11] ],
    ].map do |spec|
      assert_equal spec[0], Line.new( *spec[1] ).exist_at?( *spec[2] ),
        "expected #{ spec[0] } for line #{ spec[1] }, at #{ spec[2] }"
    end

    [ # testing rays
      [ true, [0,0,@r1], [3,3] ],
      [ true, [0,0,@r2], [-3,3] ],
      [ true, [0,0,@r3], [-3,-3] ],
      [ true, [0,0,@r4], [3,-3] ],

      [ false, [0,0,@r1], [-3,-3] ],
      [ false, [0,0,@r2], [3,-3] ],
      [ false, [0,0,@r3], [3,3] ],
      [ false, [0,0,@r4], [-3,3] ],
      # TODO add horizontal and verticals
      [ true, [0, 0, 0], [1098, 0] ],
      # [ false, [0, 0, 0], [1099, 1] ],
      # [ false, [0, 0, 0], [-1, 0] ],
    ].map do |spec|
      assert_equal spec[0], Ray.new( *spec[1] ).exist_at?( *spec[2] ),
        "expected #{ spec[0] } for line #{ spec[1] }, at #{ spec[2] }"
    end
  end

  def test_intercept
    [ # test line segments
      [ false, @q1, @q1 ],
      [ true, @q1, @q2 ],
      [ true, @q3, @q4 ],
      [ true, [*@q1,-3], [*@q2,0,1] ],
      [ true, [*@q3,3], [*@q4,0,-1] ]
    ].map do |spec|
      assert_equal spec[0],
        Line.new( *spec[1] ).intercept?( Line.new( *spec[2] ) )
    end

    [
      [ true, [0,0,@r1], [999,0,@r2] ],
      [ true, [0,0,@r1], [0,0,@r3 + 0.1] ],
      [ false, [1,-1,@r4], [-1,1,@r2] ],
      [ false, [0,0,@r1], [0,0,@r1] ]
    ].map do |spec|
      assert_equal spec[0],
        Ray.new( *spec[1] ).intercept?( Ray.new( *spec[2] ) ),
        "expected #{ spec[0] } for ray #{ spec[1] }, with ray #{ spec[2] }"
    end
  end

end

