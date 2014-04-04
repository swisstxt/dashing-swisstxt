# Populate the graph with some random points
#
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["Cloudstack+ZUERICH_IX+Memory"] = ["Cloudstack_ZUERICH_IX"]
chk = /usage_perc_MAX/

points = []

SCHEDULER.every '5m', :first_in => '5s' do

sum = 0
svc.each { |key,value|
  value.each { |host|
    data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],settings.config["nagios"]["pnp"]+"?start=-15%20Minutes&srv=#{key}&host=#{host}",settings.config["nagios"]["ssl"],settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
    data = JSON.parse(data)
    chk_num = data["meta"]["legend"]["entry"].find_index{ |e| e.match(chk)}
    sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
  }
}

  points << { x: Time.now.to_i, y: sum}

  send_event('cs_ix_ram', value: sum)
end

