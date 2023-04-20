#!/usr/bin/env ruby

require 'csv'
require 'json'

data = JSON.parse(ARGF.read[11..-1])

CSV.foreach("secondary.csv", headers: true, converters: [:numeric]) do |row|
  found = false
  data['secondary_schools'].each do |sec|
    if sec[2]['name'] == row['Schoolname']
      sec[2].merge!(row.to_h)
      found = true
      break
    end
  end
end

print "map_data = "
print data.to_json
