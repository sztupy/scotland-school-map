#!/usr/bin/env ruby

require 'base64'
require 'json'

result_data = {
  secondary_schools: [],
  primary_schools: []
}

features = []

mode = nil
school_type = 'Non-denominational'
type = :secondary_schools

def contains_point?(poly, point)
  c = false
  i = -1
  j = poly.size - 1
  while (i += 1) < poly.size
    if ((poly[i][0] <= point[0] && point[0] < poly[j][0]) ||
       (poly[j][0] <= point[0] && point[0] < poly[i][0]))
      if (point[1] < (poly[j][1] - poly[i][1]) * (point[0] - poly[i][0]) / (poly[j][0] - poly[i][0]) + poly[i][1])
        c = !c
      end
    end
    j = i
  end
  return c
end

ARGF.each_line do |line|
  if line=~/START_OF_PRIMARY_SCHOOL/
    type = :primary_schools
  elsif line=~/\((\{"bbox":.*)\)/
    features << JSON.parse($1)
  elsif line=~/circleMarker/
    mode = :circle
  elsif line=~/\[([0-9.-]*), ([0-9.-]*)\]/
    if mode == :circle
      result_data[type] << [$2.to_f, $1.to_f]
      mode = :iframe
    end
  elsif line =~ /"color": "#ff0000"/
    school_type = 'Denominational'
  elsif line=~/data:text\/html;charset=utf-8;base64,([^"]*)"/
    if mode == :iframe
      html = Base64.decode64($1)
      data = {}

      html_data = nil
      address = []
      html.each_line do |line|
        if line =~ />LA[^ ]* *([^<]*)</
          data[:local_authority] = $1
        elsif line =~ />Rank\.*([^<]*)</
          data[:rank] = $1.to_i
        elsif line =~ />Roll\.*([^<]*)</
          data[:roll] = $1.to_f
        elsif line =~ />FTE Teachers\.*([^<]*)</
          data[:fte_teachers] = $1.to_f
        elsif line =~ /\"line-height: 5px\"><b>([^<]*)<\/b>/
          data[:name] = $1
        elsif line =~ /<b>Address<\/b>/ || line =~ /<b>Website<\/b>/
          html_data = :address
        elsif line =~ />([^<]*)<\/?br>/ && html_data == :address
          addr = $1
          if addr.start_with?("http")
            data[:url] = addr
          else
            address << addr
          end
        end
      end

      data[:address] = address
      data[:type] = school_type

      result_data[type][-1][2] = data
      mode = nil
      school_type = 'Non-denominational'
    end
  end
end

result_data[:catchment] = []

features.each do |feat|
  feat["features"].each do |f|
    id = f["id"].to_i
    result_data[:catchment][id] = {
      geometry: f["geometry"],
      properties: f["properties"]
    }
  end
end


result_data[:secondary_schools].each_with_index do |school, school_id|
  catch :done do
    features.each do |feat|
      feat["features"].each do |f|
        coords = f["geometry"]["coordinates"]
        coords = [ coords ] if f["geometry"]["type"] == "Polygon"

        coords.each do |polygon|
          if contains_point?(polygon[0], school)
            id = f["id"].to_i
            result_data[:catchment][id][:properties]["secondary_schools"] ||= []
            result_data[:catchment][id][:properties]["secondary_schools"] << school_id
            school[2][:catchment_id] = id
            STDERR.puts "found sec"
            throw :done
          end
        end
      end
    end
  end
end

result_data[:primary_schools].each_with_index do |school, school_id|
  catch :done do
    features.each do |feat|
      feat["features"].each do |f|
        coords = f["geometry"]["coordinates"]
        coords = [ coords ] if f["geometry"]["type"] == "Polygon"

        coords.each do |polygon|
          if contains_point?(polygon[0], school)
            id = f["id"].to_i
            result_data[:catchment][id][:properties]["primary_schools"] ||= []
            result_data[:catchment][id][:properties]["primary_schools"] << school_id
            school[2][:catchment_id] = id
            STDERR.puts "found prim"
            throw :done
          end
        end
      end
    end
  end
end

print "map_data = "
print result_data.to_json
