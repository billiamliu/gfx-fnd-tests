module RoundingRefinement
  refine Float do

    alias :__old_round__ :round

    def round
      # this keeps pixels at the top left when split between two options
      self >= 0 ? ( self - 0.5 ).ceil : ( self + 0.5).floor
    end

  end

end

module Pixelator

  using RoundingRefinement

  module Line
    # include Enumerable

    def each
      i = 0

      case quadrant
      when :east
        while exist_at? i, 0
          yield [ i, 0 ]
          i += 1
        end
      when :north
        while exist_at? 0, i
          yield [ 0, i ]
          i += 1
        end
      when :west
        while exist_at?( -i, 0 )
          yield [ -i, 0 ]
          i += 1
        end
      when :south
        while exist_at?( 0, -i )
          yield [ 0, -i ]
          i += 1
        end
      when :q1
        if slope.abs >= 1
          while exist_at?( x = x_at( yo + i ), y = yo + i )
            yield [ x.round, y ]
            i += 1
          end
        else
          while exist_at?( x = xo + i, y = y_at( xo + i ) )
            yield [ x, y.round ]
            i += 1
          end
        end
      when :q2
        if slope.abs >= 1
          while exist_at?( x = x_at( yo + i ), y = yo + i )
            yield [ x.round, y ]
            i += 1
          end
        else
          while exist_at?( x = xo - i, y = y_at( xo - i ) )
            yield [ x, y.round ]
            i += 1
          end
        end
      when :q3
        if slope.abs >= 1
          while exist_at?( x = x_at( yo - i ), y = yo - i )
            yield [ x.round, y ]
            i += 1
          end
        else
          while exist_at?( x = xo - i, y = y_at( xo - i ) )
            yield [ x, y.round ]
            i += 1
          end
        end
      when :q4
        if slope.abs >= 1
          while exist_at?( x = x_at( yo - i ), y = yo - i )
            yield [ x.round, y ]
            i += 1
          end
        else
          while exist_at?( x = xo + i, y = y_at( xo + i ) )
            yield [ x, y.round ]
            i += 1
          end
        end
      end
    end

    def y_at x
      slope * x + bias
    end

    def x_at y
      ( y - bias ) / slope
    end

  end

  module Example

    class LineLike
      include ::Pixelator::Line
      attr_reader :xo, :yo, :slope, :quadrant

      def initialize xo, yo, slope, quadrant, range = 10
        @xo, @yo, @slope, @quadrant, @range = xo, yo, slope, quadrant, range
      end

      def bias
        # y = mx + b
        # b = y - mx
        yo - slope * xo
      end

      def exist_at? x, y
        x < @range && y < @range
      end
    end

  end

end
