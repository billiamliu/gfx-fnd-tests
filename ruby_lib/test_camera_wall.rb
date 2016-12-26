require 'minitest/autorun'
require_relative 'point_vector'
require_relative 'camera_wall'

class TestWrapper < MiniTest::Test

  def setup
    @wq1 = Wall.new 0, 10, 10, 0 # a diag wall in Q1, slope -1
    @wq2 = Wall.new 0, 10, -10, 0
    @wq3 = Wall.new 0, -10, -10, 0
    @wq4 = Wall.new 0, -10, 10, 0
    @wv = Wall.new 0, -10, 0, 10 # a vert wall passing O
    @wh = Wall.new 10, 0, -10, 0 # a horiz wall passing O

    @cv = Camera.new 0, 0, Math::PI / 2
    @ch = Camera.new 0, 0, 0

    @cq1 = Camera.new 0, 0, Math::PI / 4
    @cq2 = Camera.new 0, 0, Math::PI / 4 * 3
  end

  def test_none_intersect
    assert_equal [ false, false ],
      [ @wq1, @wq3 ]
        .map { |w| @cq1.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :parallel, :parallel ],
      [ @wq2, @wq4 ]
        .map { |w| @cq1.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ false, false ],
      [ @wq2, @wq4 ]
        .map { |w| @cq2.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :parallel, :parallel ],
      [ @wq1, @wq3 ]
        .map { |w| @cq2.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :colinear ],
      [ @wv ]
        .map { |w| @cv.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :colinear ],
      [ @wh ]
        .map { |w| @ch.intersect( w ) }
        .map { |r| r[0] }
  end

  def test_distance
    assert_equal Math.sqrt( 50 ).round( 7 ), @cq1.distance_to( @wq1 ).round( 7 )
    assert_equal nil, @cq1.distance_to( @wq2 )
    assert_equal Math.sqrt( 50 ).round( 7 ), @cq1.distance_to( @wq3 ).round( 7 ) * -1
    assert_equal nil, @cq1.distance_to( @wq4 )

    assert_equal 0, @cv.distance_to( @wh )
    assert_equal 0, @ch.distance_to( @wv )
  end

  def test_intersect
    assert_equal [ true ],
      [ @wh ]
        .map { |w| @cv.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ true ],
      [ @wv ]
        .map { |w| @ch.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ true ],
      [ @wv ]
        .map { |w| @cq1.intersect( w ) }
        .map { |r| r[0] }
  end

end

