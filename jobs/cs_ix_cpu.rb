# Populate the graph with some random points
#
require 'nagiosharder'
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["Cloudstack+ZUERICH_IX+CPU"] = ["Cloudstack_ZUERICH_IX"]
chk = /usage_perc_MAX/

points = []

SCHEDULER.every '1m', :first_in => '5s' do

sum = 0
svc.each { |key,value|
  value.each { |host|
    data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/pnp4nagios/xport/json?start=-15%20Minutes&srv=#{key}&host=#{host}",true,settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
    data = JSON.parse(data)
    chk_num = data["meta"]["legend"]["entry"].find_index{ |e| e.match(chk)}
    sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
  }
}

  points << { x: Time.now.to_i, y: sum}

  send_event('cs_ix_cpu', value: sum)
end

