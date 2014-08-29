# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'retriable'
require 'rexml/document'
include REXML

SCHEDULER.every '10m', :first_in => '15s' do |job|
  img = "http://api.teletext.ch/online/pics/medium/SRF1_882-1.gif"

  send_event('txt882', {image: img })
end

