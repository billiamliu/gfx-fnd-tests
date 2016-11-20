require 'minitest/autorun'
require_relative 'pixelator'

class TestPixelator < MiniTest::Test

  Line = Pixelator::Example::LineLike

  def test_each
    take_qty = 4
    tests = [
      {
        expected: [ [0,0], [1,0], [2,0], [3,0] ],
        input: [ 0, 0, 0, :east ]
      },
      {
        expected: [ [0,0], [0,1], [0,2], [0,3] ],
        input: [ 0, 0, nil, :north ]
      },
      {
        expected: [ [0,0], [-1,0], [-2,0], [-3,0] ],
        input: [ 0, 0, 0, :west ]
      },
      {
        expected: [ [0,0], [0,-1], [0,-2], [0,-3] ],
        input: [ 0, 0, nil, :south ]
      },
      # test Q1 two different slopes
      {
        expected: [ [0,0], [0,1], [1,2], [1,3] ],
        input: [ 0, 0, 2, :q1 ]
      },
      {
        expected: [ [0,0], [1,0], [2,1], [3,1] ],
        input: [ 0, 0, 0.5, :q1 ]
      },
      # test Q3 two different slopes
      {
        expected: [ [0,0], [-1,-1], [-1,-2], [-2, -3] ],
        input: [ 0, 0, 2, :q3 ]
      },
      {
        expected: [ [0,0], [-1,0], [-2,-1], [-3,-1] ],
        input: [ 0, 0, 0.5, :q3 ]
      },
      # test different origins
      {
        expected: [ [3,3], [4,4], [5,5], [6,6] ],
        input: [ 3, 3, 1, :q1 ]
      },
      {
        expected: [ [-3,3], [-4,4], [-5,5], [-6,6] ],
        input: [ -3, 3, -1, :q2 ]
      },
      {
        expected: [ [-3,-3], [-4,-4], [-5,-5], [-6,-6] ],
        input: [ -3, -3, 1, :q3 ]
      },
      {
        expected: [ [3,-3], [4,-4], [5,-5], [6,-6] ],
        input: [ 3, -3, -1, :q4 ]
      },
      # test a bit of everything
      {
        expected: [ [2,-3], [2,-4], [3,-5], [3,-6] ],
        input: [ 2, -3, -2, :q4 ]
      }
    ]

    tests.map do |spec|
      assert_equal spec[ :expected ],
        Line.new( *spec[ :input ] ).enum_for( :each ).take( take_qty )
    end
  end

  def test_take_range
    segment = Line.new( 0, 0, 1, :q1, 10 ).enum_for :each
    ray = Line.new( 0, 0, 1, :q1, Float::INFINITY ).enum_for( :each )

    assert segment.take( 3 ).length == 3
    assert segment.take( 10 ).length == 10
    assert segment.take( 13 ).length == 10

    assert ray.take( 3 ).length == 3
    assert ray.take( 10 ).length == 10
    assert ray.take( 848 ).length == 848
  end

end
