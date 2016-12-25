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

  def -( o )
    self.class.new( x - o.x, y - o.y )
  end

  def +( o )
    self.class.new( x + o.x, y + o.y )
  end

  # cross product
  def *( o )
    o.class == Scalar ? 
      self.class.new( x * o.c, y * o.c ) :
      Scalar.new( x * o.y - y * o.x )
  end

  def /( o )
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
    # t = ( q - p ) * s / ( r * s )
    partial = ( o.point - point ) / ( vector * o.vector )
    t = partial * o.vector
    u = partial * vector

    if vector * o.vector == 0 && ( o.point - point ) * vector == 0
      [ :colinear, nil ]
    elsif vector * o.vector == 0 && ( o.point - point ) * vector != 0
      [ :parallel, nil ]
    elsif vector * o.vector != 0 && ( 0..1 ).include?( t ) && ( 0..1 ).include?( u )
      [ true, t, u ]
    else
      [ false, t, u ]
    end
  end

  private

  def approx_zero? n
    n > ( 0 - @fuzziness ) && n < ( 0 + @fuzziness )
  end

end

a = PointVector.new( Vector.new( -5, 5 ), Vector.new( 10, 0 ) )
b = PointVector.new( Vector.new( 0, 0 ), UnitVector.new( Math::PI / 2 ) )

p b.intercept( a )
