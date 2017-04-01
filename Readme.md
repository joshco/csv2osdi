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

> csv2osdi comes with a [sample CSV](sample.csv) and config-sample to test with.

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
# this schema is for the included sample.csv file which has columns:
#
```

| 0          | 1  |  2  |   3  | 4 | 5 | 6 | 7     |  8 | 9   | 10 | 11 | 12 | 13
|-------------------------------------------------------------------------
|Household ID|Last|First|Middle|YoB|MoB|DoB|Address|City|State|Zip|Email| Volunteer_tag|color

```
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

## Logging

You can specify a log file which csv2osdi will write it's output to in addition to STDOUT.

Example output

```shell
INFO 2017-04-01 05:17:30 +0000: csv2osdi Starting up, chillin with https://actionnetwork.org/api/v2/
INFO 2017-04-01 05:17:31 +0000: All needed tags are present.  Proceeding.
INFO 2017-04-01 05:17:31 +0000: Uploading with offset 0 and limit NONE
INFO 2017-04-01 05:17:31 +0000: Uploaded row 0 Lawrence Woodard lawrence.woodard@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/730c4355-d28b-4665-b6be-094dfd6e73a3
INFO 2017-04-01 05:17:32 +0000: Uploaded row 1 Joshua Carter joshua.carter@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/4a6b4626-eb11-4c50-ac0b-cb4efbaaa5be
INFO 2017-04-01 05:17:33 +0000: Uploaded row 2 Melissa Scott melissa.scott@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/98b3ee68-1836-4640-960d-e1987206a06d
INFO 2017-04-01 05:17:34 +0000: Uploaded row 3 Richard Mcclain richard.mcclain@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/772ac5d4-62b2-4388-921f-3beb031c54ad
INFO 2017-04-01 05:17:35 +0000: Uploaded row 4 Scott Jefferson scott.jefferson@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/5746c123-2f9b-4c2a-9b74-d1863b88e4a0
INFO 2017-04-01 05:17:36 +0000: Uploaded row 5 Johnny Mathis johnny.mathis@fake.osdi.info with tags volunteer as https://actionnetwork.org/api/v2/people/812e48a6-662b-4952-ad88-fa42ac50ec29
INFO 2017-04-01 05:17:37 +0000: Uploaded row 6 Frank Charles frank.charles@fake.osdi.info with tags  as https://actionnetwork.org/api/v2/people/90910144-e8e1-48a7-8451-f358b8133b97
INFO 2017-04-01 05:17:37 +0000: Uploaded row 7 Walter Gamble walter.gamble@fake.osdi.info with tags  as https://actionnetwork.org/api/v2/people/bf024758-eea1-487e-9a74-1c626b3820e5
INFO 2017-04-01 05:17:38 +0000: Uploaded row 8 Scott Williams scott.williams@fake.osdi.info with tags  as https://actionnetwork.org/api/v2/people/d422466d-364d-4cdf-b6db-339a8be9af19
INFO 2017-04-01 05:17:38 +0000: csv2osdi finished.  Total rows 9 Successes 9 Failures 0
```

## Reference

[OSDI API Reference](http://opensupporter.github.io/osdi-docs/)

[OSDI Informational Site](http://opensupporter.org)

## License

MIT

Copyright 2017 Josh Cohen

