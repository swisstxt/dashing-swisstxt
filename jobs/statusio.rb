require 'net/http' # for polling API
require 'json'     # for parsing API response
require 'yaml'     # for parsing config file


SCHEDULER.every '5m', :first_in => '5s' do |job|
  # parse the configured URI
  uri = URI.parse(settings.config["statuspageio"]["uri"])
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme.eql? 'https'

  # poll API
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  status = JSON.parse(response.body)

  indicator    = status['status']['indicator']
  overall_status    = status['status']
  components_status = status['components'].select{|c|
    # use only the components specified in config (if any)
    unless settings.config["statuspageio"]["components"].nil?
      settings.config["statuspageio"]["components"].include? c['name']
    else
      # return all components if none specified in config
      true
    end
  }
  incidents = status['incidents']

  # Current issues are issues with a status other than 'completed' or 'resolved'
  current_issues = incidents.select{|i| !['completed','resolved'].include? i['status']}
  current_issue_count = current_issues.length

  # Count components by status
  components_status_counts = Hash.new 0
  components_status.map{|c| c['status']}.map{|c| components_status_counts[c] += 1}
 
  if indicator == 'critical'
    # if half or less of components are not 'operational' then status is 'red'
    color_status = 'red'
  elsif  indicator == 'major'
    # if there are any current issues, or more than one but less than half
    # of components are not 'operational', status is 'yellow'
    color_status = 'orange'
  elsif  indicator == 'minor'
                color_status = 'yellow'
  else
    color_status = 'green'
  end


  send_event(
    "statuspageio",
    {
      overall_status:    overall_status,
      components_status: components_status,
      issue_count:       current_issue_count,
      current_issues:    current_issues,  # not used yet
      status:            color_status
    }
  )
end
