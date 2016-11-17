#!/usr/bin/env ruby
$multiplier, inFile, outFile = ARGV
$multiplier = $multiplier.to_i
$comment_regex = /\A\s*#/

module Converter

  def self.call infile, outfile
    units = []

    infile.each do |line|
      line.split( ' ' ).each { |u| units << u } unless line =~ $comment_regex
    end

    headers = units[0] == 'P1' ? units.take( 3 ) : units.take( 4 )
    bits = units[0] == 'P1' ? units.last( units.length - 3 ) : units.last( units.length - 4 )

    bits = processBits headers[1].to_i, bits, ( units[0] == 'P3' ? 3 : 1 )
    headers = processHeaders headers

    outfile.print headers * ' '
    outfile.print $/
    outfile.print bits * ' '
  end

  private

  def self.processHeaders headers
    headers[1] = ( headers[1].to_i * $multiplier )
    headers[2] = ( headers[2].to_i * $multiplier )
    headers
  end

  def self.processBits line_size, bits, grouping
    ret = []

    bits.each_slice( line_size * grouping ).each do |line|
      row = []

      line.each_slice( grouping ).each do |u|
        $multiplier.times { row << u }
      end

      $multiplier.times { ret << row << $/ }
    end

    ret.flatten
  end

end

File.open inFile do |inf|
  File.open outFile, 'w' do |outf|
    Converter.( inf, outf )
  end
end

