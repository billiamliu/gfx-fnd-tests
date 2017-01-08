require 'minitest/autorun'
require_relative 'camera_wall'

class TestWrapper < MiniTest::Test

  def setup
    @wq1 = Wall.new 0, 10, 10, 0 # a diag wall in Q1, slope -1
    @wq2 = Wall.new 0, 10, -10, 0
    @wq3 = Wall.new 0, -10, -10, 0
    @wq4 = Wall.new 0, -10, 10, 0
    @wv = Wall.new 0, -10, 0, 10 # a vert wall passing O
    @wv3 = Wall.new 3, 10, 3, -10
    @wh = Wall.new 10, 0, -10, 0 # a horiz wall passing O
    @wh3 = Wall.new 10, 3, -10, 3

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

  def test_angles_return_qty
    fov = Math::PI / 2
    camera = Camera.new 0, 0, 0, fov

    odd = 7
    res = camera.angles odd
    assert res.length == odd
    assert_equal res.first.theta * -1, res.last.theta
    assert_equal 0.0, res[ odd / 2 ].theta, 'the middle angle should be 0 for odd resolutions'

    even = 8
    res = camera.angles even
    assert res.length == even
    assert_equal res.first.theta * -1, res.last.theta
    assert_equal(
      res[ even / 2 ].theta,
      res[ even / 2 - 1 ].theta * -1,
      'the middle two angles should have the same magnitute for even resolutions'
    )

    res = camera.angles 100
    assert res.first.theta * -1 + res.last.theta <= fov
  end

  def test_angles_degree
    camera = Camera.new 0, 0, 0, Math::PI / 2
    assert_equal(
      [ -0.71883, -0.55860, -0.35877, -0.12435, 0.12435, 0.35877, 0.55860, 0.71883 ],
      camera.angles( 8 ).map { |x| x.theta.round( 5 ) },
      'increments of theta away from center should be decreasing'
    )
  end

  def test_collision_detector
    assert_equal(
      3,
      CollisionDetector.( @rq1, [ @wq1, @wq2, @wq3, @wq4, @wh, @wv ] ).length,
      'should report all possible collisions by default'
    )
    
    assert_equal(
      1,
      CollisionDetector.( @rq1, [ @wq1, @wq1 ], :only_visible ).length,
      'should only show first/visible collision when flag is set'
    )

    assert_equal(
      1,
      CollisionDetector.( @rq1, @wq1 ).length,
      'should work with a single object to collide with; i.e. not wrapped in array'
    )

    assert_equal(
      [ nil ],
      CollisionDetector.( @rq1, @wq2, :only_visible ),
      'should not collide when given a non-collision test, and asking for visible_only'
    )
  end

  def test_filters
    ray = Ray.new 0, 0, 0

    assert_equal(
      1,
      CollisionDetector.( ray, [ @wh3, @wv3 ] ).length,
      "should show one collision when given one positive and one negative test case"
    )

  end


end





