module LineLike

  ROUNDING_ERROR = 0.001
  PI = Math::PI

  def self.equal? a, b
    a == b || ( a - b ).abs < ROUNDING_ERROR
  end

  def self.intercept_distance_between line, ray
    return nil unless ray.intercept? line
    intercept = ray.intercept_at line
    find_distance ray.xo, ray.yo, *intercept
  end

  def self.find_distance xo, yo, xe, ye
    dx = xe - yo
    dy = ye - yo
    Math.sqrt( dx ** 2.0 + dy ** 2.0 ).abs
  end

  module Ray

    include LineLike
    # This is for lines that has origin but has no end
    # therefore has already rotation, and no dx dy
    
    def rotation
      @rotation
    end

    def exist_at? x, y
      return false unless on_ray? x, y

      case quadrant
      when :east
        x >= xo
      when :west
        x <= xo
      when :north
        y >= yo
      when :south
        y <= yo
      else
        if rotation < PI
          y >= yo
        else
          y <= yo
        end
      end
    end

    def on_ray? x, y
      unless slope.nil?
        y == slope * xo + bias
      else
        x == xo
      end
    end

    def slope
      case ( rotation / ( PI / 2 ) + 1 ).floor
      when 1
        Math.tan rotation
      when 2
        -1 * Math.tan( PI - rotation ).to_f
      when 3
        Math.tan( rotation - PI ).to_f
      when 4
        -1 * Math.tan( PI - ( rotation - PI ) ).to_f
      end
    end

    def quadrant
      if rotation == 0
        :east
      elsif rotation == PI / 2
        :north
      elsif rotation == PI
        :west
      elsif rotation == PI * 1.5
        :south
      elsif rotation > 0
        :q1
      elsif rotation > PI / 2
        :q2
      elsif rotation > PI
        :q3
      elsif rotation > PI * 1.5
        :q4
      end
    end

  end

  def rotation
    case quadrant
    when :north
      PI / 2
    when :south
      PI * 1.5
    when :east
      0
    when :west
      PI
    when :q1
      theta
    when :q2
      theta + PI / 2 
    when :q3
      theta + PI
    when :q4
      theta + PI * 1.5
    end
  end

  def quadrant
    #up
    if dx == 0 && dy > 0
      :north
    #down
    elsif dx == 0 && dy < 0
      :south
    #right
    elsif dx > 0 && dy == 0
      :east
    #left
    elsif dx < 0 && dy == 0
      :west
    #Q1
    elsif dx > 0 && dy > 0
      :q1
    #Q2
    elsif dx < 0 && dy > 0
      :q2
    #Q3
    elsif dx < 0 && dy < 0
      :q3
    #Q4
    elsif dx > 0 && dy < 0
      :q4
    end
  end

  def intercept? line
    return false if parallel_to? line
    return false unless q = intercept_at( line )
    
    exist_at?( *q ) && line.exist_at?( *q )
  end

  def parallel_to? line
    min, max = [ rotation, line.rotation ].minmax
    min == max || min + PI == max
  end

  def exist_at? x, y
    return false unless on_ray? x, y
    
    case quadrant
      when :east
        y == yo && cover_x?( x )
      when :north
        x == xo && cover_y?( y )
      when :west
        y == yo && cover_x?( x )
      when :south
        x == xo && cover_y?( y )
      else
        cover_x?( x ) && cover_y?( y )
    end
  end

  def cover_x? x
    min, max = [ xo, xo + dx ].minmax
    ( min..max ).cover? x
  end

  def cover_y? y
    min, max = [ yo, yo + dy ].minmax
    ( min..max ).cover? y
  end

  def on_ray? x, y
    unless slope.nil?
      slope * x + bias
    else
      x == xo
    end
  end

  def intercept_at line
    return nil if parallel_to? line
    unless slope.nil? || line.slope.nil?
      x = ( line.bias - bias ) / ( slope - line.slope ).to_f
      y = slope * x + bias
      [ x, y ]
    else
      if slope.nil?
        [ xo, line.slope * xo + line.bias ]
      else # line.slope is nil
        [ line.xo, slope * xo + bias ]
      end
    end
  end

  def theta
    Math.atan( dy / dx ).abs
  end

  def slope
    return nil if dx == 0
    dy / dx
  end

  def bias
    yo - slope * xo
  end

  module Example

    class Line
      include LineLike

      attr_reader :dx, :dy, :xo, :yo

      def initialize dx, dy, xo = 0, yo = 0
        @dx, @dy, @xo, @yo = dx, dy, xo, yo
      end
    end

    class Ray
      include LineLike::Ray

      attr_reader :xo, :yo, :rotation

      def initialize xo = 0, yo = 0, rotation
        @xo, @yo, @rotation = xo, yo, rotation
      end
    end

  end

end
