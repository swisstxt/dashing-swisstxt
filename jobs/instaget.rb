# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'net/http'
require 'retriable'
require 'rss'


hashtag = "swisstxt"

SCHEDULER.every '2h', :first_in => '15s' do |job|
  raw = Stxtdashing.fetch_http("instagram.com","/tags/#{hashtag}/feed/recent.rss",false)
  rss = RSS::Parser.parse(raw)
  title = rss.channel.item.title
  img = rss.channel.item.link

  send_event('instaget', {image: img, title: title })
end

