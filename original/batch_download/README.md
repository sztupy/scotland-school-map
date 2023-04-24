This directory contains helper tools to batch extract school attainment and pupil information from the Smarter Scotland dashboard, which only allows downloading them by school one-by-one.

Usage:

* Tested on Firefox, but might work on Chrome as well
* Open up either the primary or secondary school dashboard. The special school dashboard does not have attainment information. Note: only download either the primary or secondary data at a time, as the format is slightly different when merging.
  * https://scotland.shinyapps.io/sg-primary_school_information_dashboard/
  * https://scotland.shinyapps.io/sg-secondary_school_information_dashboard/
* Open up the developer console
* Copy and run the contents of the `batch_download_csv.js` file into the console
* Wait for the CSV files to be downloaded - this can take a couple hours
* Copy and run the contents of the `verify_download_csv.js` file into the console
* Wait for it to finish then save the resulting string into a file called `primary.json` or `secondary.json` (example files provided in this repository)
* Copy all csv files returned into the `temp` directory. Note: do not mix primary school CSVs with secondary school CSVs!
* Run `verify_and_generate_csv_files.rb primary.json` or `verify_and_generate_csv_files.rb secondary.json` dependent on which dataset you want to get
* This will generate 4 CSV files that contains all of the data obtained from the dashboards. It will also print out if any files have been missed. Re-download them and re-run the scripts to make the results complete.
