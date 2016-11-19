require 'json'

class McParseface

  def initialize argv
    @json = File.read argv[0]
    @outfile = argv[1]
  end

  def raw_json
    @json
  end

  def spec
    @spec ||= JSON.parse @json
  end

  def walls
    spec['walls'].map( &:values )
  end

  def camera
    [ spec['camera_x'], spec['camera_y'] ]
  end

  def angles
    spec['angles']
  end

end

module LineLike

  ROUNDING_ERROR = 0.001
  PI = Math::PI

  def self.equal? a, b
    a == b || ( a - b ).abs < ROUNDING_ERROR
  end

  module Ray

    include LineLike
    # This is for lines that has origin but has no end
    # therefore has already rotation, and no dx dy
    
    def rotation
      @rotation
    end

    def exist_at? x, y
      on_ray?( x, y ) && if rotation <= PI
        y >= yo
      else
        y <= yo
      end
    end

    def on_ray? x, y
      slope * x + bias
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

  end

  def rotation_degrees
    rotation * 180 / PI
  end

  def rotation
    #up
    if dx == 0 && dy > 0
      r = PI / 2
    #down
    elsif dx == 0 && dy < 0
      r = PI * 1.5
    #right
    elsif dx > 0 && dy == 0
      r = 0
    #left
    elsif dx < 0 && dy == 0
      r = PI
    #Q1
    elsif dx > 0 && dy > 0
      r = theta
    #Q2
    elsif dx < 0 && dy > 0
      r = theta + PI / 2 
    #Q3
    elsif dx < 0 && dy < 0
      r = theta + PI
    #Q4
    elsif dx > 0 && dy < 0
      r = theta + PI * 1.5
    end

    r
  end

  def intercept? line
    return false unless q = intercept_at( line )
    
    exist_at?( *q ) && line.exist_at?( *q )
  end

  def parallel_to? line
    min, max = [ rotation, line.rotation ].minmax
    min == max || min + PI == max
  end

  def exist_at? x, y
    on_ray?( x, y ) && if dy >= 0
      ( yo..(yo + dy) ).cover? y
    else
      ( (yo + dy)..yo ).cover? y
    end
  end

  def on_ray? x, y
    slope * x + bias
  end

  def intercept_at line
    return nil if parallel_to? line
    # y = mx + b
    # x = ( b2 - b1 ) / ( m1 - m2 )
    x = ( line.bias - bias ) / ( slope - line.slope ).to_f
    y = slope * x + bias
    [ x, y ]
  end

  def theta
    Math.atan( dy / dx ).abs
  end

  def slope
    dy / dx
  end

  def bias
    yo - slope * xo
  end

end

module Pixelator

  def p
  end

  def pixels
    # TODO handle infinity with enum

    # when it's a dot return origin
    return [ [ xo, yo ] ] if dx == 0 && dy == 0

    ret = []
    xstep = dy == 0 ? 0 : dx.to_f / dy.abs # the amount of x to move per unit of y
    ystep = dx == 0 ? 0 : dy.to_f / dx.abs 

    # drawing y based on per x
    # considering 0-index which misses 1 iteration
    ( dx.to_i.abs + 1 ).times do |i|
      x = @yo + ystep * i
      y = dx < 0 ? @xo - i.to_f : @xo + i.to_f
      ret << [ x, y ].map { |n| small_round n }
    end

    # drawing x based on per y
    # considering 0-index which misses 1 iteration
    ( dy.to_i.abs + 1 ).times do |i|
      y = @xo + xstep * i
      x = dy < 0 ? @yo - i.to_f : @yo + i.to_f
      ret << [ x, y ].map { |n| small_round n }
    end

    ret.map
  end

  def small_round num
    # when a line is equally between two pixels, choose upper left
    ( num - 0.5 ).ceil
  end

end

class Line
  include LineLike

  def initialize xo:, yo:, xe:, ye:
    @xo, @yo, @xe, @ye = xo, yo, xe, ye
  end

  private

  def dx
    @xe - @xo
  end

  def dy
    @ye - @yo
  end

end

class Ray
  include LineLike::Ray

  def initialize xo:, yo:, rotation:
    @xo, @yo, @rotation = xo, yo, rotation
  end

  private

  def xo
    @xo
  end

  def yo
    yo
  end

  def rotation
    @rotation
  end
end

class Camera

  def initialize x, y
    @x, @y = x, y
  end

end

