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

class Line

  def initialize xo:, yo:, xe: Float::INFINITY, ye: Float::INFINITY, rotation: nil
    @xo, @yo, @xe, @ye, @rotation = xo, yo, xe, ye, rotation
  end

  def exists_at? x, y
    # points.index( [x, y] ) ? true : false
    equal_with_rounding?( y, slope * x + bias ) &&
      # TODO broken because of range ponting left doesn't work in ruby
      ( (@xo - ROUNDING_ERROR)..(@xe + ROUNDING_ERROR) ).cover?( x ) &&
      ( (@yo - ROUNDING_ERROR)..(@ye + ROUNDING_ERROR) ).cover?( y )
  end

  def rotation
    return @rotation if @rotation

    pi = Math::PI
    theta = -> ( x, y ) { Math.atan y / x }
    if dx == 0 && dy > 0
      r = pi / 2
    elsif dx == 0 && dy < 0
      r = pi / 2 / -1
    elsif dx > 0 && dy == 0
      r = 0
    elsif dx < 0 && dy == 0
      r = pi
    elsif dx > 0 && dy > 0
      r = theta.( dx, dy )
    elsif dx < 0 && dy > 0
      r = theta.( dx.abs, dy ) + pi / 2 
    elsif dx < 0 && dy < 0
      r = theta.( dx.abs, dy.abs ) + pi
    elsif dx > 0 && dy < 0
      r = theta.( dx.abs, dy.abs ) + pi * 1.5
    end
    @rotation = r
  end

  def rotation_degrees
    rotation * 180 / Math::PI
  end

  def parallel_to? line
    min, max = [ rotation, line.rotation ].minmax
    equal_with_rounding?( min, max ) || equal_with_rounding?( min + Math::PI, max )
  end

  def intercept_with? line
    return false if parallel_to? line
    x = ( line.bias - bias ) / ( slope - line.slope )
    y = slope * x + bias
    exists_at?( x, y ) && line.exists_at?( x, y )
  end

  protected

  def slope
    Math.tan rotation
  end

  def bias
    @yo - slope * @xo
  end

  private

  ROUNDING_ERROR = 0.01

  def equal_with_rounding? a, b
    a == b || ( a - b ).abs < ROUNDING_ERROR
  end

  def points
    @points ||= calc_points
  end

  def dx
    @xe - @xo
  end

  def dy
    @ye - @yo
  end

  def calc_points
    # TODO replace with OO module

    # when it's a dot return origin
    return [ [ @xo, @yo ] ] if dx == 0 && dy == 0

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

    ret
  end

  def small_round num
    # when +/- 0.5, round towards 0
    ( num - 0.5 ).ceil
  end

end

class Camera

  def initialize x, y
    @x, @y = x, y
  end

end

q2_horizontal = Line.new xo: -1, yo: 1, xe: -10, ye: 1
q2_horizontal_2 = Line.new xo: -1, yo: 2, xe: -10, ye: 2
h2_vertical = Line.new xo: -5, yo: 10, xe: -5, ye: -10
q4_cam_45 = Line.new xo: 1, yo: -9, rotation: Math::PI / 4
q4_cam_135 = Line.new xo: 1, yo: -10, rotation: Math::PI / 4 * 3

p q2_horizontal.intercept_with? h2_vertical # true
# p q2_horizontal_2.intercept_with? q2_horizontal # false
# p q4_cam_135.intercept_with? h2_vertical # true
# p q4_cam_45.intercept_with? h2_vertical # false

