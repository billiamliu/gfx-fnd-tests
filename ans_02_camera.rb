require 'json'
require_relative 'attempt/line_like'
require_relative 'attempt/pixelator'

class Wall
  include LineLike

  attr_reader :xo, :yo, :xe, :ye, :id

  def initialize xo, yo, xe, ye, id
    @xo, @yo, @xe, @ye, @id = xo, yo, xe, ye, id
  end

  def dx
    @xe - @xo
  end

  def dy
    @ye - @yo
  end

end

class Sight
  include LineLike::Ray

  attr_reader :xo, :yo, :rotation, :id

  def initialize xo, yo, rotation, id
    @xo, @yo, @rotation, @id = xo, yo, rotation, id
  end

  def rotation= new_r
    Sight.new xo: xo, yo: yo, rotation: new_r
  end

end

# things specfic to this attempt, below:

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

  def camera_rotations
    spec['angles']
  end

end

class CollisionDetector

  def initialize walls, sight
    @walls, @sight = walls, sight
  end

  def distance_between wall, sight
    LineLike.intercept_distance_between wall, sight
  end

  def collisions
    @walls
      .take_while { |wall| wall.intercept? @sight }
      .map do |wall|
        { wall: wall.id, distance: distance_between( wall, @sight ) }
      end
      .sort_by { |res| res[:distance] }
  end

end

class Attempt

  def initialize spec, wall, sight
    @spec, @wall, @sight = spec, wall, sight
  end

  def get_collisions walls, sight
    CollisionDetector.new( walls, sight ).collisions
  end

  def call
    sights.map { |s| get_collisions( walls, s ) }
  end

  private

  def walls
    @spec.walls.each_with_index.map do |coords,i|
      @wall.new( *coords, i )
    end
  end

  def sights
    @spec.camera_rotations.each_with_index.map do |r,i|
      @sight.new( *@spec.camera, r, i )
    end
  end
    
end

parsed = McParseface.new ARGV
p Attempt.new( parsed, Wall, Sight ).()















