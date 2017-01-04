require 'minitest/autorun'
require_relative 'camera_wall'

class TestWrapper < MiniTest::Test

  def setup
    @wq1 = Wall.new 0, 10, 10, 0 # a diag wall in Q1, slope -1
    @wq2 = Wall.new 0, 10, -10, 0
    @wq3 = Wall.new 0, -10, -10, 0
    @wq4 = Wall.new 0, -10, 10, 0
    @wv = Wall.new 0, -10, 0, 10 # a vert wall passing O
    @wh = Wall.new 10, 0, -10, 0 # a horiz wall passing O

    @rv = Ray.new 0, 0, Math::PI / 2
    @rh = Ray.new 0, 0, 0

    @rq1 = Ray.new 0, 0, Math::PI / 4
    @rq2 = Ray.new 0, 0, Math::PI / 4 * 3
  end

  def test_none_intersect
    assert_equal [ false, false ],
      [ @wq1, @wq3 ]
        .map { |w| @rq1.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :parallel, :parallel ],
      [ @wq2, @wq4 ]
        .map { |w| @rq1.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ false, false ],
      [ @wq2, @wq4 ]
        .map { |w| @rq2.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :parallel, :parallel ],
      [ @wq1, @wq3 ]
        .map { |w| @rq2.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :colinear ],
      [ @wv ]
        .map { |w| @rv.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ :colinear ],
      [ @wh ]
        .map { |w| @rh.intersect( w ) }
        .map { |r| r[0] }
  end

  def test_intersect
    assert_equal [ true ],
      [ @wh ]
        .map { |w| @rv.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ true ],
      [ @wv ]
        .map { |w| @rh.intersect( w ) }
        .map { |r| r[0] }

    assert_equal [ true ],
      [ @wv ]
        .map { |w| @rq1.intersect( w ) }
        .map { |r| r[0] }
  end

  def test_angles
    # TODO refine test for accuracy
    camera = Camera.new 0, 0, 0, Math::PI / 2
    res = camera.angles 40
    assert res.length == 40
  end

  def test_collision_detector
    assert_equal(
      6,
      CollisionDetector.( @rq1, [ @wq1, @wq2, @wq3, @wq4, @wh, @wv ] ).length,
      'should report all collisions by default'
    )
    
    assert_equal(
      1,
      CollisionDetector.( @rq1, [ @wq1, @wq2, @wq3, @wq4, @wh ], true ).length,
      'should only show first collision when flag is set'
    )

    assert_equal(
      1,
      CollisionDetector.( @rq1, @wq2 ).length,
      'should work with a single object to collide with; i.e. not wrapped in array'
    )

    assert_equal(
      [ nil ],
      CollisionDetector.( @rq1, @wq2, true ),
      'should not collide when given a non-collision test, and asking for visible_only'
    )
  end


end





