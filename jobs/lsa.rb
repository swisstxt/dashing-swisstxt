# Populate the graph with some random points
#
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["Icecast_Listeners"] = ["stxts00101.swisstxt.ch","stxts00102.swisstxt.ch","stxts00103.swisstxt.ch","stxts00104.swisstxt.ch","lsa-ed02-eq-p.swisstxt.ch","lsa-ed01-eq-p.swisstxt.ch","stxts10101.swisstxt.ch","stxts10102.swisstxt.ch","stxts10103.swisstxt.ch","stxts10104.swisstxt.ch","lsa-ed02-ix-p.swisstxt.ch","lsa-ed01-ix-p.swisstxt.ch"]
svc["Wowza+Listeners"] = ["stxts00107.swisstxt.ch","stxts00108.swisstxt.ch","stxts10107.swisstxt.ch","stxts10108.swisstxt.ch"]
chk = "total_listeners_MAX"

points = []

SCHEDULER.every '5m', :first_in => '13s' do
  begin
    sum = 0
    svc.each { |key,value|
      value.each { |host|
        data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],settings.config["nagios"]["pnp"]+"?start=-15%20Minutes&srv=#{key}&host=#{host}",settings.config["nagios"]["ssl"],settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
        data = JSON.parse(data)
        chk_num = data["meta"]["legend"]["entry"].index(chk)
        sum = sum+data["data"]["row"][5]["v"][chk_num].to_f.to_i
      }
    }

    points << { x: Time.now.to_i, y: sum}

    send_event('lsa', points: points)
  rescue => e
  end
end
