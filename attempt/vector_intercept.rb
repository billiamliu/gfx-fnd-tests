class Scalar

  attr_reader :c

  def initialize constant
    @c = constant
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

end

class Vector

  attr_reader :x, :y

  def initialize x, y
    @x, @y = x, y
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
      self.class.new( x * o.c, y * o.c ) :
      Scalar.new( x * o.y - y * o.x )
  end

  def / o
    o.class == Scalar ?
      self.class.new( x / o.c, y / o.c ) :
      Scalar.new( x / o.x + y / o.y )
  end

end

class UnitVector < Vector

  def initialize theta
    super Math.cos( theta ), Math.sin( theta )
  end

end

class PointVector

  attr_reader :point, :vector

  def initialize point, vector, fuzziness = 0.0001
    @point, @vector, @fuzziness = point, vector, fuzziness
  end

  def intercept o
    # p + tr = q<vector> + u<scalar>s<vector>
    # NOTE t is the scaling factor for this line to intercept other
    # t = ( q - p ) * s / ( r * s )
    r, s = vector, o.vector
    p, q = point, o.point
    rs = r * s
    q_p = q - p
    partial = q_p / rs
    t = partial * s
    u = partial * r

    if rs == 0 && q_p * r == 0
      [ :colinear, nil ]
    elsif rs == 0 && q_p * r != 0
      [ :parallel, nil ]
    elsif rs != 0 && ( 0..1 ).include?( t ) && ( 0..1 ).include?( u )
      [ true, p + t * r, t, u ]
    else
      [ false, t, u ]
    end
  end

  private

  # TODO test approx parallel lines to see if this is still needed
  def approx_zero? n
    n > ( 0 - @fuzziness ) && n < ( 0 + @fuzziness )
  end

end

# a = PointVector.new( Vector.new( -5, 5 ), Vector.new( 10, 0 ) )
# b = PointVector.new( Vector.new( 0, 0 ), UnitVector.new( Math::PI / 2 ) )
# p b.intercept( a )
