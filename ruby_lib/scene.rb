require_relative 'camera_wall'

class PixelExtractor
  # converts walls into pixel values
  attr_accessor :telemetry

  def self.call object
    build.( object )
  end

  def self.build
    new
  end

  def self.configure receiver
    receiver.pretty_printer = build
  end

  def call wall
    record :interpreting_colour, wall
    wall.colour
  end

  private

  def record action, data
    telemetry.record( action, data ) if telemetry
    data
  end

end


class HorizonExpander
  
  attr_accessor :telemetry
  attr_accessor :pretty_printer
  
  def self.call horizon_array, resolution
    build.( horizon_array, resolution )
  end

  def self.configure receiver
    receiver.horizon_expander = build
  end

  def self.build
    new.tap do |ins|
      PixelExtractor.configure ins
    end
  end

  def call horizon_array, resolution
    throw ArgumentError, "resolution must be even" if resolution % 2 != 0

    record :begin_expanding

    ret = horizon_array.map do |point|
      distance = distance_of point
      height_percent = height_at distance
      fill = get_fill_from point
      fill_column resolution, height_percent, fill
    end
      .reverse
      .transpose

    record :end_expanding, ret
  end

  private

  def get_fill_from point
    record :getting_fill_from, point
    ret = point[ 1 ]
    ret = pretty_printer.( ret ) if pretty_printer
    ret
  end

  def record event, payload = nil
    telemetry.record( event, payload ) if telemetry
    payload
  end

  def fill_column height, fill_percent, fill
    record :filling_column, [ height, fill_percent, fill ]

    fill_height = even_round( height * fill_percent )
    padding = ( height - fill_height ) / 2
    payload = Array.new( fill_height ) { fill }

    empty_column_of( padding ) + payload + empty_column_of( padding )
  end

  def even_round num
    # NOTE imprecise way of handling non-even pixels
    num.ceil % 2 == 0 ? num.ceil : num.floor
  end

  def empty_column_of qty
    Array.new( qty ) { nil }
  end

  def height_at distance
    half_res = 32
    fov = Math::PI / 2
    pixel_height = Math.tan( fov / 2.0 ) / half_res

    wall_half_height = ( 1 / 2 ** distance ) / 2
    pixel_qty = wall_half_height / pixel_height
    pixel_qty / half_res
  end

  def height_at distance
    # NOTE old, linear fisheye
    1 / 2 ** distance # returns percentage in terms of 1.00
  end

  def distance_of data_point
    intersect = data_point[ 0 ]
    intersect.scalar
  end

end


class Display
  # converts nested array into pixel grid
  
  attr_accessor :telemetry

  def self.call scene
    build.( scene )
  end

  def self.build
    new
  end

  def self.configure receiver
    receiver.display = build
  end

  def call scene
    throw ArgumentError, "not implemented yet"
  end

  private

  def record action, data
    telemetry.record( action, data ) if telemetry
    data
  end

  module Substitute

    def self.build
      Display.build
    end

    class Display < ::Display

      def call scene
        record :converting_scene_for_display, scene

        ret = ""

        scene.each do |row|
          row.each do |col|
            col.nil? ? ret << "." : ret << "X"
            ret << " "
          end

          ret << $/
        end

        puts ret

        ret
      end

    end

  end

end


class SceneExtrapolator

  attr_accessor :telemetry
  attr_writer :collision_detector
  attr_writer :horizon_expander
  attr_writer :display
  
  def self.call camera, walls, resolution
    build.( camera, walls, resolution )
  end

  def self.build
    new.tap do |ins|
      CollisionDetector.configure ins
    end
  end
  
  def call camera, walls, resolution
    rays = camera_rays( camera, resolution )
    get_collisions_for_rays( rays, walls )
    # expand horizon into 2D
  end

  def record event, payload
    telemetry.record( event, payload ) if telemetry
    payload
  end

  private

  def camera_rays camera, resolution
    record :getting_camera_rays, [ camera, resolution ]
    camera.angles resolution
  end

  def get_collisions_for_rays angles, walls
    record :getting_collisions, [ angles, walls ]
    angles.map { |angle| collision_detector.( angle, walls, true ).first }
  end

  def collision_detector
    @collision_detector ||= CollisionDetector::Substitute.build
  end

  module Substitute

    def build
      SceneExtrapolator.new
    end

    class SceneExtrapolator < ::SceneExtrapolator
      def call 
        record :extrapolated_scene, ret
      end
    end
  end

end
