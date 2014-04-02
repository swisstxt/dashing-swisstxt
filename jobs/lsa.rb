# Populate the graph with some random points
#
require 'nagiosharder'
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["check_icecast_Listeners"] = ["stxts00101","stxts00102","stxts00103","stxts00104","stxts00105","stxts00106","stxts10101","stxts10102","stxts10103","stxts10104","stxts10105","stxts10106"]
svc["check_wowza_Listeners"] = ["stxts00107","stxts00108","stxts10107","stxts10108"]
chk = "total_listeners_MAX"

points = []

SCHEDULER.every '10m', :first_in => '13s' do

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

  send_event('lsa', points: points)
end
