require_relative 'point_vector'

class Camera < PointVector

  attr_reader :x, :y, :theta

  def initialize x, y, theta
    super( Vector.new( x, y ), UnitVector.new( theta ) )
    @x, @y, @theta = x, y, theta
  end

  def set_theta t
    @theta = t
    self
  end

  def set_x new_x
    @x = new_x
    self
  end

  def set_y new_y
    @y = new_y
    self
  end

  def distance_to o
    result = intersect( o )

    case result[ 0 ]
    when :colinear
    when :parallel
      nil
    when true
      x = result[ 1 ].x
      y = result[ 1 ].y
      pythagora x, y
    when false
      result[ 1 ].c
    end
  end

  private

  def pythagora x, y
    Math.sqrt( x * x + y * y )
  end
    
end


module ImmutableCamera

  refine Camera do
    
    def set_theta t
      self.class.new( x, y, t )
    end

    def set_x new_x
      self.class.new( new_x, y, theta )
    end

    def set_y new_y
      self.class.new( x, new_y, theta )
    end

  end

end


class Wall < PointVector

  attr_reader :colour

  def initialize xo, yo, xe, ye, colour = 0xCCCCCC
    super( Vector.new( xo, yo ), Vector.new( xe - xo, ye - yo ) )
  end

end

class CollisionDetector

  def self.call camera, walls
  end

  def initialize camera, walls
    @camera, @walls = camera, walls
  end

  def collisions
    hot @camera, @walls
  end

  private

  def camera_theta c
    c.theta
  end

  def intersect l1, l2
    l1.intersect( l2 ).distance
  end

  def hot camera, walls
    walls.map do |w|
      [ camera_theta( camera ), intersect( camera, w ), w ]
    end
  end

  # testing with arrays instead of PointVectors
  def null camera, walls
    # TODO
  end

end
