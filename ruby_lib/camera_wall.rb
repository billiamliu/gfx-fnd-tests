require_relative 'point_vector'

class Ray < PointVector

  attr_reader :x, :y, :theta
  
  def initialize x, y, theta
    super Vector.new( x, y ), UnitVector.new( theta )
    @x, @y, @theta = x, y, theta
  end

  def to_s
    "<Ray x:#{ x } y:#{ y } theta:#{ theta }>"
  end

end

class Camera

  attr_reader :x, :y, :theta, :fov

  def initialize x, y, theta, fov
    @x, @y, @theta, @fov = x, y, theta, fov
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

  def set_fov new_fov
    @fov = new_fov
    self
  end

  def angles resolution
    # NOTE this is the old one that should give fisheye
    # TODO test against new one
    increment = fov / resolution
    start = theta - fov / 2 + increment / 2

    resolution.times.map do |n|
      Ray.new( x, y, start + increment * n )
    end
  end

  def angles resolution
    half_res = resolution / 2.0
    pixel_width = Math.tan( fov / 2.0 ) / half_res

    resolution.times.map do |n|

      start = 0 - half_res + 0.5
      pixel_x = ( start + n ) * pixel_width
      angle = theta + Math.atan( pixel_x )

      Ray.new x, y, angle
    end
  end

end


module ImmutableCamera

  refine Camera do
    
    def set_theta t
      self.class.new( x, y, t, fov )
    end

    def set_x new_x
      self.class.new( new_x, y, theta, fov )
    end

    def set_y new_y
      self.class.new( x, new_y, theta, fov )
    end

    def set_fov new_fov
      self.class.new( x, new_y, theta, new_fov )
    end

  end

end


class Wall < PointVector

  attr_reader :colour

  def initialize xo, yo, xe, ye, colour = 1
    super( Vector.new( xo, yo ), Vector.new( xe - xo, ye - yo ) )
    set_colour colour
  end

  def set_colour colour
    @colour = colour
  end

end


class CollisionDetector

  attr_writer :intersector
  attr_accessor :telemetry

  def self.call subject, objects, only_visible = nil
    build.( subject, objects, only_visible )
  end

  def self.configure receiver
    receiver.collision_detector = build
  end

  def self.build
    new.tap do |ins|
      Intersector.configure ins
    end
  end

  def call subject, objects, only_visible = nil
    record :calculating_collisions

    objects = [ objects ] unless objects.respond_to? :map

    ret = objects.map do |o|
      [ intersect( subject, o ), o ]
    end

    ret = filter_negative( ret )
    ret = filter_visible( ret ) if only_visible == :only_visible

    record :calculated_collisions, ret
  end

  private

  def filter_negative results
    record :filtering_negative

    results.take_while do |result|
      result[ 0 ].possible?
    end
  end

  def filter_visible results
    record :filtering_visible

    closest = results.reduce( nil ) do |accumulator, result|
      intersect, _ = result
      if intersect.possible?
        unless accumulator.nil?
          intersect.scalar < accumulator[ 0 ].scalar &&intersect.scalar >= 0 ? result : accumulator
        else
          result
        end
      else
        accumulator
      end
    end

    record :filtered_visible, [ closest ]
  end

  def intersector
    @intersector ||= Intersector::Substitute.build
  end

  def record event, payload = nil
    telemetry.record( event, payload ) if telemetry
    payload
  end

  def intersect l1, l2
    intersector.( l1, l2 )
  end

  module Substitute

    def build
      CollisionDetector.new
    end

    class CollisionDetector < ::CollisionDetector
      def call subject, objects, only_visible = false
        ret = [ :null ]
        record :calculated_collisions, ret
      end
    end
  end

end
