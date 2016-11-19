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

  module Ray

    include LineLike
    # This is for lines that has origin but has no end
    # therefore has already rotation, and no dx dy
    
    def rotation
      @rotation
    end

    def exist_at? x, y
      # TODO test it
      on_ray?( x, y ) && if rotation <= Math::PI
        y >= yo
      else
        y <= yo
      end
    end

  end

  def rotation_degrees
    rotation * 180 / Math::PI
  end

  def rotation
    pi = Math::PI

    #up
    if dx == 0 && dy > 0
      r = pi / 2
    #down
    elsif dx == 0 && dy < 0
      r = pi * 1.5
    #right
    elsif dx > 0 && dy == 0
      r = 0
    #left
    elsif dx < 0 && dy == 0
      r = pi
    #Q1
    elsif dx > 0 && dy > 0
      r = theta
    #Q2
    elsif dx < 0 && dy > 0
      r = theta + pi / 2 
    #Q3
    elsif dx < 0 && dy < 0
      r = theta + pi
    #Q4
    elsif dx > 0 && dy < 0
      r = theta + pi * 1.5
    end

    r
  end

  def intercept? line
    return false unless q = intercept_at( line )
    
    exist_at?( *q ) && line.exist_at?( *q )
  end

  def parallel_to? line
    min, max = [ rotation, line.rotation ].minmax
    equal?( min, max ) || equal?( min + Math::PI, max )
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

  # private

  ROUNDING_ERROR = 0.001

  def equal? a, b
    a == b || ( a - b ).abs < ROUNDING_ERROR
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
  include ::LineLike
  include ::Pixelator

  def initialize xo:, yo:, xe: Float::INFINITY, ye: Float::INFINITY, rotation: nil
    @xo, @yo, @xe, @ye, @rotation = xo, yo, xe, ye, rotation
  end

  def exist_at? x, y
    min_x, max_x = [ @xo, @xe ].minmax
    min_y, max_y = [ @yo, @ye ].minmax

    ( (min_x - ROUNDING_ERROR)..(max_x + ROUNDING_ERROR) ).cover?( x ) &&
      ( (min_y - ROUNDING_ERROR)..(max_y + ROUNDING_ERROR) ).cover?( y )
  end

  def intercept_with? line
    return false if parallel_to? line
    x = ( line.bias - bias ) / ( slope - line.slope )
    y = slope * x + bias
    p x
    p y
    exist_at?( x, y ) && line.exist_at?( x, y )
  end

  private

  def dx
    @xe - @xo
  end

  def dy
    @ye - @yo
  end

end

class Camera

  def initialize x, y
    @x, @y = x, y
  end

end

