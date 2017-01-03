require 'minitest/autorun'
require_relative 'point_vector'
require_relative 'telemetry'

class TestPointVector < MiniTest::Test

  def setup
    @h0 = PointVector.from_a [ [ -10, 0 ], [ 20, 0 ] ]
    @h7 = PointVector.from_a [ [ -10, 7 ], [ 20, 0 ] ]
    @h_7 = PointVector.from_a [ [ -10, -7 ], [ 20, 0 ] ]
    @v0 = PointVector.from_a [ [ 0, -10 ], [ 0, 20 ] ]
    @v5 = PointVector.from_a [ [ 5, -10 ], [ 0, 20 ] ]
    @v_5 = PointVector.from_a [ [ -5, -10 ], [ 0, 20 ] ]
    @q_up = PointVector.from_a [ [ 0, 0 ], [ 0, 1 ] ]
    @q1 = PointVector.from_a [ [ 0, 0 ], [ 1, 1 ] ]
    @q1_long = PointVector.from_a [ [ 0, 0 ], [ 10, 10 ] ]
  end

  def test_parallel
    assert_equal [ :parallel, nil ], @h0.intersect( @h7 )
    assert_equal [ :parallel, nil ], @h0.intersect( @h_7 )
    assert_equal [ :parallel, nil ], @h7.intersect( @h_7 )

    assert_equal [ :parallel, nil ], @v0.intersect( @v5 )
    assert_equal [ :parallel, nil ], @v0.intersect( @v_5 )
    assert_equal [ :parallel, nil ], @v5.intersect( @v_5 )

    assert_equal [ :parallel, nil ], @q_up.intersect( @v_5 )
  end

  # TODO add overlapping tests once module is done
  def test_colinear
    assert_equal [ :colinear, nil ], @h0.intersect( @h0 )
  end

  def test_intersect
    assert_equal [ true, Vector.new( 0, 0 ), Scalar.new( 0.5 ), Scalar.new( 0.5 ) ], @h0.intersect( @v0 )
    assert_equal [ true, Vector.new( 5, 7 ), Scalar.new( 0.75 ), Scalar.new( 0.85 ) ], @h7.intersect( @v5 )
    assert_equal [ true, Vector.new( -5, -7 ), Scalar.new( 0.25 ), Scalar.new( 0.15 ) ], @h_7.intersect( @v_5 )
    assert_equal [ true, Vector.new( 7, 7 ), Scalar.new( 0.7 ), Scalar.new( 0.85 ) ], @q1_long.intersect( @h7 )
  end

  def test_none_intersect
    assert_equal [ false, Scalar.new( 7 ), Scalar.new( 0.5 ) ], @q_up.intersect( @h7 )
    assert_equal [ false, Scalar.new( -7 ), Scalar.new( 0.5 ) ], @q_up.intersect( @h_7 )
    assert_equal [ false, Scalar.new( 5 ), Scalar.new( 0.75 ) ], @q1.intersect( @v5 )
    assert_equal [ false, Scalar.new( -5 ), Scalar.new( 0.25 ) ], @q1.intersect( @v_5 )
  end

  def test_length
    assert_equal 20, @h0.length
    assert_equal 20, @v0.length
    assert_equal Math.sqrt( 2 ), @q1.length
    assert_equal Math.sqrt( 200 ), @q1_long.length
  end

  def test_approx_zero_slope
    l1 = PointVector.from_a [ [ -1_000_000, 0 ], [ 2_000_000, 0 ] ]
    l2 = PointVector.from_a [ [ -1_000_000, 0.000_000_1 ], [ 2_000_000, -0.000_000_2 ] ]
    assert_equal [ true, Vector.new( 0, 0 ), Scalar.new( 0.5 ), Scalar.new( 0.5 ) ], l1.intersect( l2 )
  end

  def test_useful_intersector
    intersector = Intersector.build point_vector_1: @h0, point_vector_2: @v0
    Telemetry.configure intersector

    intersect = intersector.()
    assert_equal true, intersect[ 0 ]

    intersect = Intersector.( point_vector_1: @h0, point_vector_2: @v0 )
    assert_equal true, intersect[ 0 ]
  end

  def test_useful_intersector_substitute
    intersector = Intersector::Substitute.build point_vector_1: @h0, point_vector_2: @v0
    telemetry = Telemetry.configure intersector

    assert_equal :null, intersector.().first
    assert_equal 1, telemetry.sink.length
  end

end

