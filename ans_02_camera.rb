require 'json'
require_relative 'attempt/line_like'
require_relative 'attempt/pixelator'

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
