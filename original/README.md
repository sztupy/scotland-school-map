`index.html` is based on data found on https://datamap-scotland.co.uk/ for both primary and secondary schools.

* `extract.rb` will extract this data into machine readable JSON.

* `add_from_csv.rb` will in turn add even more details from the data downloaded from statistics.gov: https://statistics.gov.scot/resource?uri=http%3A%2F%2Fstatistics.gov.scot%2Fdata%2Fbreadth-and-depth

The resulting file after running both calls is the `output.js` found in the root directory
