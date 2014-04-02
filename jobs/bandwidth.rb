# Populate the graph with some random points
#
require 'nagiosharder'
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'
require 'yaml'

svc = Hash.new
svc["SwCoreIX01_po2"] = ["SwCoreIX01.ix"]
svc["swfeedcu01_po20"] = ["SwFeedCU01"]
svc["SwCoreIX02_po2"] = ["SwCoreIX02.ix"]
chk = /.*out_bps_MAX/

points = []
#  hist = JSON.parse(settings.history['bw'].sub(/^[\w\s:]*/,""))
#  send_event('bw', points: hist['points'])

SCHEDULER.every '10m', :first_in => '10s' do

sum = 0
svc.each { |key,value|
  value.each { |host|
    data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/pnp4nagios/xport/json?start=-15%20Minutes&srv=#{key}&host=#{host}",true,settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
    data = JSON.parse(data)
    chk_num = data["meta"]["legend"]["entry"].find_index{ |e| e.match(chk)}
    sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
  }
}

  points << { x: Time.now.to_i, y: sum/1048576}

  send_event('bw', points: points)

end

