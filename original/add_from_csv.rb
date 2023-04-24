#!/usr/bin/env ruby

require 'csv'
require 'json'

data = JSON.parse(ARGF.read[11..-1])

parsed_data = {}

CSV.foreach("secondary_full.csv", headers: true, converters: [:numeric]) do |row|
  next unless row['School Comparator'] == 'Real Establishment'
  next unless row['Courses'] == 'All Courses'

  name = "#{row['FeatureCode']}|#{row['FeatureName']}"
  date = row['DateCode'][/[0-9]{4}/].to_i
  value = row['Value'].to_i
  if row['DataMarker'] == 'c'
    # c -> confidential
    value = -1
  elsif row['DataMarker'] == 'z'
    # z -> N/A
    value = nil
  end
  # x -> not available; w -> no data recorded

  awards = row['Number Of Awards'][/\d+/].to_i - 1
  scqf = row['SCQF Level'][/\d+/].to_i - 1

  parsed_data[name] ||= {}
  parsed_data[name][date] ||= []
  parsed_data[name][date][scqf] ||= []
  if parsed_data[name][date][scqf][awards]
    STDERR.puts row.to_h
    STDERR.puts parsed_data[name][date][scqf][awards]
  end
  parsed_data[name][date][scqf][awards] = value
end

# some school names are present multiple times, hacky way to make sure we assign the values correctly
Duplicates = {
  "St Ninian's High School" => {
    "East Renfrewshire" => 8602433,
    "East Dunbartonshire" => 8337934
  },
  "Trinity High School" => {
    "Renfrewshire" => 8632030,
    "South Lanarkshire" => 8458030
  },
  "Notre Dame High School" => {
    "Glasgow City" => 8436134,
    "Inverclyde" => 8645132
  }
}

# fill in values where datamarker was 'c' with values from the right side of the award table. We always know there are at least that many awards. We convert the number to float though to signal the FE that the value is approximate
parsed_data.each_pair do |k,v|
  v.each_pair do |kk,vv|
    vv.each do |vvv|
      last_value = 0.0
      (vvv.length-1).downto(0) do |idx|
        if vvv[idx] == -1
          vvv[idx] = last_value
        end
        if vvv[idx]
          last_value = vvv[idx].to_f
        end
      end
    end
  end

  code,name = *k.split('|')

  found = false
  data['secondary_schools'].each do |sec|
    if sec[2]['name'] == name
      if Duplicates[name]
        next if Duplicates[name][sec[2]['local_authority']].to_s != code
      end

      if found
        STDERR.puts "Duplicate #{code} - #{name}"
      end

      sec[2]['awards'] = v
      found = true
    end
  end

  if !found
    STDERR.puts "Could not map school #{name} #{code}"
  end

  found = false
  data['catchment'].each do |cat|
    if cat['properties']['Schoolname'] == name
      if Duplicates[name]
        next if cat['properties']['seed_code'].to_s != code
      end

      if found
        STDERR.puts "Duplicate #{code} - #{name}"
      end

      cat['properties']['awards'] = v
      found = true
    end
  end

  if !found
    STDERR.puts "Could not map catchment #{name} #{code}"
  end
end

print "map_data = "
print data.to_json

#print parsed_data.to_json
