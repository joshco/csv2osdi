# csv2osdi

csv2osdi is a command-line utility to upload a CSV file of people into an [OSDI](http://opensupporter.org) compliant system.  It features the ability to assign tags on a per row basis and has a configurable schema for csv files.

It can also verify that the remote system has the necessary tags before the upload. (Some systems require them to be created in advance)

For systems that do not natively support phone numbers, csv2osdi can be configured to map them to custom fields on the remote system.

> Action Network requires this

## Compliance

csv2osdi requires a working AEP and [osdi:person_signup_helper](http://opensupporter.github.io/osdi-docs/person_signup.html) to operate.

## Install and Usage

1. Clone this repository
2. Run '''bundle install'''
3. Copy config-sample.yml to config.yml
4. Edit config to your liking
5. run ./csv2osdi

> If you are on Windows, run bundle exec ruby csv2osdi.rb

> csv2osdi comes with a sample CSV and config-sample to test with.

## Configuration

### config.yml

```yaml

# filename for csv file
csv: sample.csv

# Your OSDI API Token
osdi_api_token: <%= ENV['OSDI_API_TOKEN'] %>

# Your OSDI system's AEP URL
osdi_aep_url: https://actionnetwork.org/api/v2/

# Content Type for OSDI requests.
request_content_type: application/json #(default: application/json)

# Start at the following row
# offset: 2 # default 0

# Limit number of rows, good for testing.  Additive to offset
#row_limit: 4 # default none

# Before doing upload, make sure the remote system has the needed tags created already and it not, abort.
verify_tags_first: true

# number of times to retry a given row. Useful for timeouts
max_retries: 5

# Log file
#log_file: output.log

# show detailed HTTP logs of requests
http_log: false

# just log OSDI signup helper objects
osdi_log: false

# the schema representing your CSV file structure
# For each field, set the column number with a zero based integer.
# Eg, the first column is column 0
schema:
  email_address: 11
  given_name: 2 #first name
  family_name: 1 # last name
  #mobile_phone: 3
  locality: 8 # city
  region: 9 # state
  postal_code: 10 # zip code

  # set any column to be the specified custom field on the remote system
  custom_fields:
    favorite_color: 13

  # the presence of any value in the specified column means that this row should be tagged with the specified tag name
  tags:
    volunteer: 12
    #foobar: 13
    #volunteer_master: 14

  # if your system does not natively support phone numbers, they can be inserted into custom fields named below
  phone_custom_fields:
    mobile_phone: mobile_phone
    home_phone: mobile_phone




```

## Reference

[OSDI API Reference](http://opensupporter.github.io/osdi-docs/)

[OSDI Informational Site](http://opensupporter.org)

## License

MIT

Copyright 2017 Josh Cohen

