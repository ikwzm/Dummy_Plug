#!/usr/bin/env ruby

require 'yaml'

while file_name = ARGV.shift
  File.open(file_name) do |stream|
    begin
      YAML.load_stream(stream)
    rescue Exception => error
      warn error.message
    end
  end
end
