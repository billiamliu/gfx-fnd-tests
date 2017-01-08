require 'minitest/autorun'
require_relative 'telemetry'
require_relative 'scene'
require_relative 'camera_wall'

class TestSceneExtrapolator < MiniTest::Test

  def setup
    @wq1 = Wall.new 0, 0.3, 3, 0 # a diag wall in Q1, slope -1
    @wv = Wall.new 10, -10, 10, 10 # vert line passing x = 10
    @wh = Wall.new 10, 10, -10, 10 # hori line passing y = 10
    @wh2 = Wall.new 10, 2, -10, 2

    @cq1 = Camera.new 0, 0, Math::PI / 4, Math::PI / 2
    @cv = Camera.new 0, 0, Math::PI / 2, Math::PI / 2
  end

  def test_extrapolator
    extrapolator = SceneExtrapolator.build
    horizon = extrapolator.( @cq1, @wq1, 64 )
    expander = HorizonExpander.build

    scene = expander.( horizon, 64 )

    Display::Substitute.build.( scene )
  end


end

class TestHorizonExpander < MiniTest::Test



end
