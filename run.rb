#!/usr/bin/env ruby
$multiplier, inFile, outFile = ARGV
$multiplier = $multiplier.to_i
$comment_regex = /\A\s*#/

module Converter

  def self.call infile, outfile
    units = []
    infile.each do |line|
      unless line =~ $comment_regex
        # ret = line.length > 5 ? multiply( line ) : line
        # puts ret
        # outfile.print ret
        line.split( ' ' ).each { |u| units << u }
      end
    end
    meta = units[0] == 'P1' ? units.take( 3 ) : units.take( 4 )
    bits = units[0] == 'P1' ? units.last( units.length - 3 ) : units.last( units.length - 4 )

    bits = processBits meta[1].to_i, bits, (units[0] == 'P3' ? 3 : 1)
    meta = processMeta meta

    outfile.print meta * ' '
    outfile.print $/
    outfile.print bits * ' '
  end

  def self.multiply line
    one_line = ''
    line.split( ' ' ).each { |n| $multiplier.to_i.times do one_line << "#{n} " end }
    ret = ''
    $multiplier.times do |l| ret << one_line << $/ end 
    ret
  end

  def self.processMeta meta
    meta[1] = ( meta[1].to_i * $multiplier ).to_s
    meta[2] = ( meta[2].to_i * $multiplier ).to_s
    meta
  end

  def self.processBits size, bits, grouping = 1
    ret = []
    bits.each_slice( size * grouping ).each do |line|
      row = []
      line.each_slice( grouping ).each do |u|
        $multiplier.times do row << u end
      end
      $multiplier.times do ret << row << $/ end
    end

    ret.flatten
  end

  def self.processP3Bits size, bits
  end

end

File.open inFile do |inf|
  File.open outFile, 'w' do |outf|
    Converter.( inf, outf )
  end
end

