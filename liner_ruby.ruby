#!/usr/bin/env ruby
puts ARGV

module Liner

  def self.normalise argv
    width, height = argv[0].split 'x'
    start_x, start_y = argv[1].split ','
    end_x, end_y = argv[2].split ','
    { width: width, height: height, start_x: start_x, start_y: start_y, end_x: end_x, end_y: end_y }
  end


end

puts Liner.normalise ARGV
