class Scalar
  include Comparable

  LIMIT = 0.000_000_1

  def self.from_a arr
    new arr.first
  end

  def initialize constant
    @c = constant.to_f
  end

  def c
    ( -LIMIT .. LIMIT ).include?( @c ) ? 0.0 : @c
  end

  def + o
    self.class.new( c + o.c )
  end

  def - o
    self.class.new( c - o.c )
  end

  def * o
    o.is_a?( Vector ) ?
      Vector.new( o.x * c, o.y * c ) :
      self.class.new( c * o.c )
  end

  def / o
    o.is_a?( Vector ) ?
      Vector.new( o.x / c, o.y / c ) :
      self.class.new( c / o.c )
  end

  def <=> o
    c <=> o.c
  end

  def to_a
    [ @c ]
  end

  def to_f
    @c
  end

end


class Vector

  def self.from_a arr
    new( arr[0], arr[1] )
  end

  attr_reader :x, :y

  def initialize x, y
    @x, @y = [ x, y ].map { |n| n.to_f }
  end

  def - o
    self.class.new( x - o.x, y - o.y )
  end

  def + o
    self.class.new( x + o.x, y + o.y )
  end

  # cross product
  def * o
    o.is_a?( Scalar ) ?
      mult_scalar( o ) :
      Scalar.new( x * o.y - y * o.x )
  end
  
  # dot product
  def dot o
    o.is_a?( Scalar ) ?
      mult_scalar( o ) :
      Scalar.new( x * o.x + y * o.y )
  end

  def / o
    o.is_a?( Scalar ) ?
      self.class.new( x / o.c, y / o.c ) :
      throw( "cannot divid a vector by another vector" )
  end

  def == o
    x == o.x && y == o.y
  end

  def to_a
    [ @x, @y ]
  end

  private

  def mult_scalar o
    self.class.new( x * o.c, y * o.c )
  end

end


class UnitVector < Vector

  def initialize theta
    super Math.cos( theta ), Math.sin( theta )
  end

end


class PointVector

  def self.from_a arr
    v1, v2 = arr.map { |v| Vector.new( *v ) }
    new( v1, v2 )
  end

  attr_reader :point, :vector

  def initialize point, vector
    @point, @vector = point, vector
  end

  def length
    Math.sqrt vector.x * vector.x + vector.y * vector.y
  end

  # TODO pending deprecation because of Intersector class
  def intersect o
    # NOTE http://stackoverflow.com/a/565282
    # p + t r = q + u s
    # t = ( q - p ) * s / ( r * s )
    r, s = vector, o.vector
    p, q = point, o.point
    rs = r * s
    q_p = q - p

    if rs == zero && q_p * r == zero
      # NOTE for calculating overlap
      # t0 = ( q - p ) dot r / ( r dot r )
      # t1 = ( q + s - p ) dot r / ( r dot r )
      # t1 = t0 + s dot r / ( r dot r )
      return [ :colinear, nil ]
    elsif rs == zero && q_p * r != zero
      return [ :parallel, nil ]
    end

    t = q_p * s / rs
    u = q_p * r / rs

    if rs != zero && ( 0..1 ).include?( t.c ) && ( 0..1 ).include?( u.c )
      return [ true, p + t * r, t, u ]
    else
      return [ false, t, u ]
    end
  end

  def to_a
    [ [ point.x, point.y ], [ vector.x, vector.y ] ]
  end

  private

  def zero
    @zero ||= Scalar.new 0
  end

end


class Intersect

  attr_reader :type, :intersection

  def self.types
    [ :null, :colinear, :parallel, :intersect, :non_intersect ]
  end

  def initialize type = :null, scalar_1 = nil, scalar_2 = nil, intersection = nil
    set_type type

    set_scalars( scalar_1, scalar_2 ) unless scalar_1.nil?
    set_intersection( intersection ) unless intersection.nil?
  end

  def possible?
    type_check = type != :colinear && type != :parallel && type != :null
    value_check = type_check && @scalar_1 >= 0 && (0..1).cover?( @scalar_2 )
    type_check && value_check
  end

  def intersector_scalar
    @scalar_1
  end
  alias_method :scalar, :intersector_scalar

  def scalars
    [ @scalar_1, @scalar_2 ]
  end

  private

  def set_type type
    @type = type
  end

  def set_scalars one, two
    if type == :intersect || type == :non_intersect
      @scalar_1, @scalar_2 = one, two
    else
      throw ArgumentError, 'only intersect and potential intersect can have scalar values for the P and Q lines'
    end
  end

  def set_intersection coord
    if type == :intersect
      @intersection == coord
    else
      throw ArgumentError, 'only intersect lines can have an intersection'
    end
  end

end


class Intersector
  # NOTE Intersect is a Value Object dependency, consider refactor

  attr_accessor :telemetry

  def self.call pv1, pv2
    build.( pv1, pv2 )
  end
  
  def self.configure receiver
    receiver.intersector = build
  end

  def self.build
    new
  end

  def call pv1, pv2
    find_intersect pv1, pv2
  end

  private

  def record event, payload
    telemetry.record( event, payload ) if telemetry
    payload
  end

  def find_intersect pv1, pv2
    record :finding_intersect, [ pv1, pv2 ]

    # NOTE http://stackoverflow.com/a/565282
    # p + t r = q + u s
    # t = ( q - p ) * s / ( r * s )
    r, s = pv1.vector, pv2.vector
    p, q = pv1.point, pv2.point
    rs = r * s
    q_p = q - p

    rs_zero = is_zero? rs
    qpr_zero = is_zero? q_p * r

    if rs_zero && qpr_zero
      # NOTE for calculating overlap
      # t0 = ( q - p ) dot r / ( r dot r )
      # t1 = ( q + s - p ) dot r / ( r dot r )
      # t1 = t0 + s dot r / ( r dot r )
      return record :calculated_intersect, Intersect.new( :colinear )
    elsif rs_zero && !qpr_zero
      return record :calculated_intersect, Intersect.new( :parallel )
    end

    t = q_p * s / rs
    u = q_p * r / rs

    if !rs_zero && ( 0..1 ).include?( t.c ) && ( 0..1 ).include?( u.c )
      return record :calculated_intersect, Intersect.new( :intersect, t.to_f, u.to_f, ( p + t * r ).to_a )
    else
      return record :calculated_intersect, Intersect.new( :non_intersect, t.to_f, u.to_f )
    end

  end

  def is_zero? scalar
    scalar.c == 0
  end


  module Substitute

    def self.build
      Intersector.new
    end

    class Intersector < ::Intersector

      private

      def find_intersect pv1, pv2
        record( :found_intersect, Intersect.new )
      end
      
    end

  end

end












