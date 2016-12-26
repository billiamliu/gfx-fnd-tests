require 'minitest/autorun'
require_relative 'vector_intercept'

class TestVectorIntercept < MiniTest::Test

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
    assert_equal [ :parallel, nil ], @h0.intercept( @h7 )
    assert_equal [ :parallel, nil ], @h0.intercept( @h_7 )
    assert_equal [ :parallel, nil ], @h7.intercept( @h_7 )

    assert_equal [ :parallel, nil ], @v0.intercept( @v5 )
    assert_equal [ :parallel, nil ], @v0.intercept( @v_5 )
    assert_equal [ :parallel, nil ], @v5.intercept( @v_5 )

    assert_equal [ :parallel, nil ], @q_up.intercept( @v_5 )
  end

  # TODO add overlapping tests once module is done
  def test_colinear
    assert_equal [ :colinear, nil ], @h0.intercept( @h0 )
  end

  def test_intercept
    assert_equal [ true, Vector.new( 0, 0 ), Scalar.new( 0.5 ), Scalar.new( 0.5 ) ], @h0.intercept( @v0 )
    assert_equal [ true, Vector.new( 5, 7 ), Scalar.new( 0.75 ), Scalar.new( 0.85 ) ], @h7.intercept( @v5 )
    assert_equal [ true, Vector.new( -5, -7 ), Scalar.new( 0.25 ), Scalar.new( 0.15 ) ], @h_7.intercept( @v_5 )
    assert_equal [ true, Vector.new( 7, 7 ), Scalar.new( 0.7 ), Scalar.new( 0.85 ) ], @q1_long.intercept( @h7 )
  end

  def test_none_intercept
    assert_equal [ false, Scalar.new( 7 ), Scalar.new( 0.5 ) ], @q_up.intercept( @h7 )
    assert_equal [ false, Scalar.new( -7 ), Scalar.new( 0.5 ) ], @q_up.intercept( @h_7 )
    assert_equal [ false, Scalar.new( 5 ), Scalar.new( 0.75 ) ], @q1.intercept( @v5 )
    assert_equal [ false, Scalar.new( -5 ), Scalar.new( 0.25 ) ], @q1.intercept( @v_5 )
  end

end

