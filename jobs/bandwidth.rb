# Populate the graph with some random points
#
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'
require 'yaml'

svc = Hash.new
svc["swcoreeq01_po310"] = ["swcoreeq01.stxt.media.int"]
svc["swcoreeq02_po311"] = ["swcoreeq02.stxt.media.int"]
svc["swcoreix01_po2"] = ["swcoreix01.stxt.media.int"]
svc["swcoreix02_po2"] = ["swcoreix02.stxt.media.int"]
chk = /.*out_bps_MAX/
points = []

SCHEDULER.every '10s', :first_in => '10s' do
  begin
    sum = 0
      svc.each { |key,value|
        value.each { |host|
          data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],settings.config["nagios"]["pnp"]+"?start=-15%20Minutes&srv=#{key}&host=#{host}",settings.config["nagios"]["ssl"],settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
          data = JSON.parse(data)
          chk_num = data["meta"]["legend"]["entry"].find_index{ |e| e.match(chk)}
          sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
        }
      }
    points << { x: Time.now.to_i, y: sum/1048576}
    send_event('bw', points: points)
  rescue => e
  end
end

