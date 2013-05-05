#!/usr/bin/env ruby

codes = { }
counter = 0
until $stdin.eof?
  l = $stdin.readline
  l.gsub!(/(_)([0-9]+)/) do | m |
    # $stderr.puts " m = #{m}"
    codes[m] ||= "#{$1}#{counter += 1}"
  end
  puts l
end
