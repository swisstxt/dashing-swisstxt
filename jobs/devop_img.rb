# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'retriable'
require 'rexml/document'
include REXML

SCHEDULER.every '2h', :first_in => '15s' do |job|
  raw = Stxtdashing.fetch_http("devopsreactions.tumblr.com","/rss",false)
  doc = REXML::Document.new(raw)
  title = XPath.first(doc, "rss/channel/item/title").to_s.match(/>(.*)</)[1]
  img = XPath.first(doc, "rss/channel/item/description").to_s.match(/src="(.*.gif)"/)[1]

  send_event('devopimg', {image: img, title: title })
end

