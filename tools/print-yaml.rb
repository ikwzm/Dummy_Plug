#!/usr/bin/env ruby

require 'yaml'
require 'pp'

while file_name = ARGV.shift
  File.open(file_name) do |stream|
    data = YAML.load_stream(stream)
    pp data
  end
end
