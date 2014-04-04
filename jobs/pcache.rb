require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["Status"] = ["pcache04.swisstxt.ch","pcache05.swisstxt.ch","pcache11.swisstxt.ch","pcache12.swisstxt.ch","pcache13.swisstxt.ch"]
chk = "ActiveConn_MAX"

points = []

SCHEDULER.every '10m', :first_in => '10s' do

sum = 0
svc.each { |key,value|
  value.each { |host|
    data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/pnp4nagios/xport/json?start=-15%20Minutes&srv=#{key}&host=#{host}",true,settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
    data = JSON.parse(data)
    chk_num = data["meta"]["legend"]["entry"].index(chk)
    sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
  }
}

  points << { x: Time.now.to_i, y: sum}

  send_event('pcache_stats', points: points)
end
