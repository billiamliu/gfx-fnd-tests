#!/usr/bin/env ruby

module Liner

  def normalise argv
    width, height = argv[0].split( 'x' ).map( &:to_i )
    start_x, start_y = argv[1].split( ',' ).map( &:to_i )
    end_x, end_y = argv[2].split( ',' ).map( &:to_i )
    outfile = argv[3]
    { width: width, height: height, xo: start_x, yo: start_y, xe: end_x, ye: end_y, outfile: outfile }
  end

  def make_matrix_2d width:, height:, fill: 0, **_
    Array.new( height ) { Array.new width, fill }.freeze
  end

  def make_points xo:, yo:, xe:, ye:, **_

    # find diff, could be negative int
    dx = ( xe - xo ).to_f
    dy = ( ye - yo ).to_f

    # when it's a dot return origin
    return [ [ xo, yo ] ] if dx == 0 && dy == 0

    ret = []
    xstep = dy == 0 ? 0 : dx / dy.abs # the amount of x to move per unit of y
    ystep = dx == 0 ? 0 : dy / dx.abs 

    # drawing y based on per x
    # considering 0-index which misses 1 iteration
    ( dx.to_i.abs + 1 ).times do |i|
      x = yo + ystep * i
      y = dx < 0 ? xo - i.to_f : xo + i.to_f
      ret << [ x, y ].map { |n| small_round n }
    end

    # drawing x based on per y
    # considering 0-index which misses 1 iteration
    ( dy.to_i.abs + 1 ).times do |i|
      y = xo + xstep * i
      x = dy < 0 ? yo - i.to_f : yo + i.to_f
      ret << [ x, y ].map { |n| small_round n }
    end

    ret.freeze

  end

  def make_p1_template width:, height:, **_

    headers = "P1 #{ width } #{ height } #{ $/ }"

    -> grid do
      grid.each do |line|
        headers << line * ' '
        headers << $/
      end

      headers
    end

  end

  private

  def small_round num
    # when +/- 0.5, round towards 0
    ( num - 0.5 ).ceil
  end

  def draw_line_on_matrix line, matrix
    m = matrix.dup

    line.each do |point|
      m[ point[0] ][ point[1] ] = 1
    end

    m.freeze
  end

  def convert_to_pnm width:, height:, data:
    p data
  end

end

class Line
  extend Liner

  def self.call argv
    args = normalise argv
    m = make_matrix_2d args
    l = make_points args
    combiner = make_p1_template args

    grid = draw_line_on_matrix l, m
    combiner.( grid )
  end

end


data = Line.( ARGV )
File.write( ARGV[3], data )
# puts data
# puts "Wrote to file #{ ARGV[3] }" if File.write( ARGV[3], data )
