class Scalar
  include Comparable

  def self.from_a arr
    new arr.first
  end

  attr_reader :c

  def initialize constant
    @c = constant.to_f
  end

  def + o
    self.class.new c + o.c
  end

  def - o
    self.class.new c - o.c
  end

  def * o
    o.class == Vector ?
      Vector.new( o.x * c, o.y * c ) :
      self.class.new( c * o.c )
  end

  def / o
    o.class == Vector ?
      Vector.new( o.x / c, o.y / c ) :
      self.class.new( c / o.c )
  end

  def <=> o
    c <=> o.c
  end

  def to_a
    [ @c ]
  end

end

class Vector

  def self.from_a arr
    new( arr[0], arr[1] )
  end

  attr_reader :x, :y

  def initialize x, y
    @x, @y = [ x, y ].map { |n| n.to_f }
  end

  def - o
    self.class.new( x - o.x, y - o.y )
  end

  def + o
    self.class.new( x + o.x, y + o.y )
  end

  # cross product
  def * o
    o.class == Scalar ? 
      mult_scalar( o ) :
      Scalar.new( x * o.y - y * o.x )
  end
  
  # dot product
  def dot o
    o.class == Scalar ? 
      mult_scalar( o ) :
      Scalar.new( x * o.x + y * o.y )
  end

  def / o
    o.class == Scalar ?
      self.class.new( x / o.c, y / o.c ) :
      throw( "cannot divid a vector by another vector" )
  end

  def == o
    x == o.x && y == o.y
  end

  def to_a
    [ @x, @y ]
  end

  private

  def mult_scalar o
    self.class.new( x * o.c, y * o.c )
  end

end

class UnitVector < Vector

  def initialize theta
    super Math.cos( theta ), Math.sin( theta )
  end

end

class PointVector

  def self.from_a arr
    v1, v2 = arr.map { |v| Vector.new( *v ) }
    new( v1, v2 )
  end

  attr_reader :point, :vector

  def initialize point, vector
    @point, @vector = point, vector
  end

  def length
    Math.sqrt vector.x * vector.x + vector.y * vector.y
  end

  def intersect o
    # NOTE http://stackoverflow.com/a/565282
    # p + t r = q + u s
    # t = ( q - p ) * s / ( r * s )
    r, s = vector, o.vector
    p, q = point, o.point
    rs = r * s
    q_p = q - p

    if rs == zero && q_p * r == zero
      # NOTE for calculating overlap
      # t0 = ( q - p ) dot r / ( r dot r )
      # t1 = ( q + s - p ) dot r / ( r dot r )
      # t1 = t0 + s dot r / ( r dot r )
      return [ :colinear, nil ]
    elsif rs == zero && q_p * r != zero
      return [ :parallel, nil ]
    end

    t = q_p * s / rs
    u = q_p * r / rs

    if rs != zero && ( 0..1 ).include?( t.c ) && ( 0..1 ).include?( u.c )
      return [ true, p + t * r, t, u ]
    else
      return [ false, t, u ]
    end
  end

  def to_a
    [ [ point.x, point.y ], [ vector.x, vector.y ] ]
  end

  private

  def zero
    @zero ||= Scalar.new 0
  end

end
