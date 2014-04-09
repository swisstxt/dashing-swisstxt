# Populate the graph with some random points
#
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["check_icecast_Listeners"] = ["stxts00101","stxts00102","stxts00103","stxts00104","stxts00105","stxts00106","stxts10101","stxts10102","stxts10103","stxts10104","stxts10105","stxts10106"]
svc["check_wowza_Listeners"] = ["stxts00107","stxts00108","stxts10107","stxts10108"]
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
