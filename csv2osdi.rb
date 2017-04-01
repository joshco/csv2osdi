#!/usr/bin/env ruby
require_relative 'lib/setup'

APP_CONFIG = YAML.load(ERB.new(File.read("config.yml")).result(binding)).with_indifferent_access

if log_file_name=APP_CONFIG[:log_file].presence
  log_file=File.open(log_file_name, "a")
  log_fd=MultiIO.new(STDOUT, log_file)
else
  log_fd=STDOUT
end

logger=Logger.new(log_fd)
logger.datetime_format = '%Y-%m-%d %H:%M:%S'
logger.formatter = proc do |severity, datetime, progname, msg|
  "#{severity} #{datetime}: #{msg}\n"
end

limit=APP_CONFIG[:row_limit]
offset=APP_CONFIG[:offset] || 0
max_retries=APP_CONFIG[:max_retries].presence || 3

logger.info "csv2osdi Starting up, chillin with #{APP_CONFIG[:osdi_aep_url]}"


osdi=OSDI.new(
    api_token: APP_CONFIG[:osdi_api_token],
    aep_url: APP_CONFIG[:osdi_aep_url],
    debug: APP_CONFIG[:http_log] || false,
    request_content_type: APP_CONFIG[:request_content_type]
)


if APP_CONFIG[:verify_tags_first]==true
  my_tags=Set.new((APP_CONFIG.dig(:schema, :tags)||{}).map { |k, v| k.downcase })

  system_tags= Set.new(osdi.system_tags.map { |t| t[:name] })

  diff=my_tags - system_tags

  if diff.present?
    logger.info "Missing Tags, cannot proceed until you create these tags: #{diff.map(&:to_s)}"

  else
    logger.info "All needed tags are present.  Proceeding."
  end
end


importer=Importer.new
importer.filename=APP_CONFIG[:csv]
importer.limit=limit
importer.offset=offset
importer.schema=APP_CONFIG[:schema]
osdi_rows=importer.run



errors_count=0
success_count=0
rows_count=0

i=offset
logger.info("Uploading with offset #{offset} and limit #{limit || 'NONE'}")

osdi_rows.each do |r|
  retry_attempts=0
  begin
    info=Mixer.osdi_info(r)

    logger.debug "Processing #{r}" if APP_CONFIG[:osdi_log]==true

    response=osdi.signup(r)
    self_link=response._links[:self]

    logger.info "Uploaded row #{i} #{info} as #{self_link}"
    success_count+=1

  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => ex
    unless retry_attempts > (max_retries-1)
      retry_attempts+=1
      logger.warn "Timeout on row #{i} #{info} retrying #{retry_attempts}"
      retry

    else
      logger.error "Unresolvable error, skipping #{info}"
      errors_count+=1
    end

  rescue Faraday::ClientError => ex
    logger.warn "Error for row #{i} #{info} #{ex.message} #{ex.try(:response).try(:[], :body)}"
    errors_count+=1
  end

  i+=1

  rows_count+=1

end

logger.info("csv2osdi finished.  Total rows #{rows_count} Successes #{success_count} Failures #{errors_count}")


