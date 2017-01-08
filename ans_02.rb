#!/usr/bin/env ruby

require 'json'
require_relative 'ruby_lib/camera_wall'


module WallRefinement
  refine Wall do
    attr_accessor :id
  end
end
# NOTE this file context has refinement
using WallRefinement



class McParseface

  # TODO implement null behaviour

  def self.call
    build.()
  end

  def self.configure receiver
    receiver.input = build
  end

  def self.build
    new
  end

  def call
    spec = parse_spec
    cameras = get_cameras spec
    walls = get_walls spec
    { cameras: cameras, walls: walls }
  end

  private

  def json
    File.read ARGV[ 0 ]
  end

  def parse_spec
    JSON.parse json
  end

  def get_cameras spec
    angles = spec[ 'angles' ]
    angles.map { |angle| [ spec[ 'camera_x' ], spec[ 'camera_y' ], angle ] }
  end

  def get_walls spec
    spec[ 'walls' ].map.with_index { |w, i| [ i, w["x0"], w["y0"], w["x1"], w["y1"] ] }
  end

  module Substitute

    def self.configure receiver
      receiver.input = build
    end

    def self.build
      McParseface.new
    end

    class McParseface < ::McParseface
      def call
        { cameras: [ [0.5,1,0] ], walls: [ [123, 3, -2, 3, 2] ] }
        # NOTE below is a good candidate for null, not as substitute
        # { cameras: [], walls: [] }
      end
    end

  end

end


class McWriteface

  attr_writer :path

  def self.call data
    build.( data )
  end

  def self.configure receiver
    receiver.output = build
  end

  def self.build
    new.tap do |instance|
      instance.path = ARGV[ 1 ]
    end
  end

  def call data
    File.open( path, 'w' ) { |fh| fh.puts data }
  end

  private

  def path
    @path ||= '/dev/null'
  end

  module Substitute

    # NOTE substitutes to STDOUT rather than write to file

    def self.configure receiver
      receiver.output = build
    end

    def self.build
      McWriteface.new
    end

    class McWriteface < ::McWriteface
      def call data
        p data
      end
    end

  end

end


class Formatter

  attr_writer :logic

  def self.call collision_data
    build.( collision_data )
  end

  def self.configure receiver
    receiver.formatter = build
  end

  def self.build
    new.tap do |instance|
      instance.logic = hot
    end
  end

  def call collision_data
    logic.( collision_data )
  end

  private

  def logic
    @logic ||= ->( x ){ x }
  end

  def self.hot
    ->( collision_data ) {
      formatted = collision_data.map do |data|
        if w = data[ :wall ]
          { "wall" => w.id, "distance" => data[ :distance ] }
        else
          { "wall" => nil, "distance" => nil }
        end
      end

      { "collisions" => formatted }.to_json
    }
  end

end


class Attempt

  attr_writer :telemetry
  attr_writer :collision_detector
  attr_writer :input, :output
  attr_writer :formatter

  def self.call
    build.()
  end

  def self.build
    new.tap do |instance|
      CollisionDetector.configure instance
      McParseface.configure instance
      # McWriteface::Substitute.configure instance # NOTE substitute puts to stdout
      McWriteface.configure instance
      Formatter.configure instance
    end
  end

  def collision_detector
    @collision_detector ||= CollisionDetector.new
  end
  
  def input
    @input ||= McParseface::Substitute.build
  end

  def output
    @output ||= McWriteface::Substitute.build
  end

  def formatter
    @formatter ||= Formatter.new
  end

  def call
    parsed = input.()
    rays = make_rays parsed[ :cameras ]
    walls = make_walls parsed[ :walls ]
    c = get_collisions rays, walls
    c = formatter.( c )
    output.( c )
  end

  private

  def make_rays rays
    rays.map { |r| Ray.new( *r ) }
  end

  def make_walls walls
    walls.map do |wall|
      id = wall.shift
      Wall.new( *wall ).tap { |w| w.id = id }
    end
  end

  def get_collisions rays, walls
    rays.map do |ray|
      collision = collision_detector.( ray, walls, :only_visible ).first
      if collision
        { wall: collision[ 1 ], distance: collision[ 0 ].scalar }
      else
        { wall: nil, distance: nil }
      end
    end
  end

end


Attempt.()
# writer = McWriteface.new.tap { |instance| instance.path = ARGV[ 1 ] }
# attempt = Attempt.build.tap { |ins| ins.output = writer }
# attempt.()
