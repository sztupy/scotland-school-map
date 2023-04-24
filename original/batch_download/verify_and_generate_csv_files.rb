#!/usr/bin/env ruby

require 'csv'
require 'json'
require 'fileutils'

verify_data = JSON.parse(ARGF.read)

headers = {}

id = 1;

Dir.glob("temp/**/*.csv") do |filename|
  puts filename
  first = true
  second = true
  out_file = nil
  CSV.foreach(filename) do |row|
    if first
      h = row.join("-")
      if !headers[h]
        headers[h] = {
          id: id,
          file: CSV.open("#{id}.csv","w+"),
          list: JSON.parse(verify_data.to_json),
          row_def: h
        }
        id+=1
        headers[h][:file] << row
      end
      out_file = headers[h]
      first = false
    else
      out_file[:file] << row
      if second
        la = row[3]
        sn = row[4]
        out_file[:list][la].delete(sn)
        second = false
      end
    end
  end
end

headers.each_pair do |k,v|
  p v[:id]
  p v[:row_def]
  v[:list].delete_if {|k,v| v == []}
  p v[:list]
  v[:file].close
end

headers.each_pair do |k,v|
  system("cat #{v[:id]}.csv | (sed -u 1q; sort) | uniq > #{v[:id]}_sorted.csv")
end
