require 'json'
require_relative 'attempt/line_like'
require_relative 'attempt/collision_detector'


class McParseface

  def initialize argv
    @json = File.read argv[0]
    @outfile = argv[1]
  end

  def spec
    @spec ||= JSON.parse @json
  end

  def walls
    spec["walls"].map { |w| [ w["x0"], w["y0"], w["x1"], w["y1"], w["color"] ] }
  end

  def colours # [ ground, sky ]
    [ spec["ground_color"], spec["sky_color"] ]
  end

  def camera
    c = spec["camera"]
    [ c["x"], c["y"], c["theta"], c["h_fov"], c["width"], c["height"] ]
  end

end


class Scene
  
  # dependency CollisionDetector Grid Horizon

  attr_reader :width, :height

  def initialize width, height
    @width, @height = width, height
  end

  # attributes

  def scene
    @scene ||= Grid.new( width, height )
    @scene.grid
  end

  def horizon
    @horizon ||= Horizon.new width
  end

  def collision_detector
    @collision_detector || CollisionDetector.new
  end

  # optional dependencies

  def camera= camera
    throw "camera has different width than scene's horizon" if camera.fov_angles.length != horizon.width

    @camera = camera
    apply_camera_to_horizon
  end
  
  def walls= walls
    @walls = walls
  end

  def grid= g
    @grid = g
  end

  def collision_detector= d
    @collision_detector = d
  end

  def horizon= h
    @horizon = h
  end

  private

  def apply_collision_to_horizon
    collisions = @collision_detector.collisions
    collisions
      .map { |angle| [ angle[0], visible_collision( angle[1] ) ] }
      .each do |angle|
        angle, collision = angle
      end
  end

  def visible_collision list
    list
      .sort_by { |dist, wall| dist }
      .first
  end
  
  def apply_camera_to_horizon
    @horizon = @horizon.map.with_index do |pixel, i|
      _angle, content = pixel #<Array [ angle, content ] >
      [ @camera.fov_angles[ i ], content ]
    end
  end

  def apply_camera_to_horizon
    @camera.fov_angles.each do |angle|
      @horizon.set angle
    end
  end

end

Angle = Struct.new( :angle, :content ) do
  def set new_content
    self.new( angle, new_content )
  end
end

class Grid

  def initialize width, height, sky = 1, ground = 8
    @width, @height, @sky, @ground = width, height, sky, ground
  end

  def grid
    @grid ||= empty
  end

  private

  def empty
    [ @sky, @ground ].map { |c| Array.new( @height / 2 ) { Array.new( @width, c ) } }
      .flatten( 1 )
  end
end

class Horizon

  attr_reader :width

  def initialize width
    @width = width
  end

  def horizon
    @horizon ||= empty
  end

  def get angle
    horizon[ angle ]
  end

  def set angle, val = nil
    horizon[ angle ] = val
  end

  private

  def empty
    Hash.new { |k,v| k[v] = nil }
  end

end


class Wall
  include LineLike

  attr_reader :xo, :yo, :xe, :ye, :colour, :id

  def initialize xo, yo, xe, ye, colour, id
    @xo, @yo, @xe, @ye, @colour, @id = xo, yo, xe, ye, colour, id
  end

  def dx
    @xe - @xo
  end

  def dy
    @ye - @yo
  end

end


class Camera
  include LineLike::Ray
  DefaultAdjacent = 1

  attr_reader :xo, :yo, :rotation, :h_fov, :h_resolution

  def initialize xo, yo, rotation, h_fov, *_other
    @xo, @yo, @rotation, @h_fov = xo, yo, rotation, h_fov
  end

  def rotation= new_r
    @rotation = new_r
  end

  def h_resolution= res
    @h_resolution = res
  end

  def fov_angles
    start = - h_resolution / 2 + 0.5

    h_resolution.times.map do |n|
      angle_at_pixel( start + n ) + rotation
    end
  end

  private

  def angle_at_pixel opposite
    Math.atan( opposite / DefaultAdjacent )
  end

end

scene = Scene.new 40, 30
scene.scene.map { |l| p l }

walls = [
  Wall.new( -5, 2, 5, 2, 0x00ff00, 1 ),
  Wall.new( -5, 3, 5, 3, 0x0000ff, 2 )
]
camera = Camera.new( 0, 0, Math::PI / 2, Math::PI / 2 )
camera.h_resolution = 40

scene.camera = camera
p scene.horizon

detect = CollisionDetector.configure scene
detect.walls = walls
detect.rays = camera.fov_angles.map do |angle|
  c = camera.clone
  c.rotation = angle
  c
end
# detect.collisions.map { |x| p x }
