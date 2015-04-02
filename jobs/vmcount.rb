# Populate the graph with some random points
#
require 'json'
require 'net/http'
require 'net/https'
require 'retriable'

svc = Hash.new
svc["ESX+Runtime"] = ["cu01-pod01-esx01.stxt.media.int","cu01-pod01-esx02.stxt.media.int","cu01-pod01-esx03.stxt.media.int","cu01-pod01-esx04.stxt.media.int","cu01-pod01-esx05.stxt.media.int","cu01-srv-esx-001.stxt.media.int","cu01-srv-esx-002.stxt.media.int","cu01-srv-esx-003.stxt.media.int","cu01-srv-esx-004.stxt.media.int","cu01-srv-esx-005.stxt.media.int","cu01-srv-esx-006.stxt.media.int","cu01-srv-esx-007.stxt.media.int","cu01-srv-esx-008.stxt.media.int","cu01-srv-esx-009.stxt.media.int","cu01-srv-esx-010.stxt.media.int","ix-pod01-esx01.stxt.media.int.ix","ix-pod01-esx02.stxt.media.int.ix","ix-pod01-esx03.stxt.media.int.ix","ix-pod01-esx04.stxt.media.int.ix","ix-pod01-esx05.stxt.media.int.ix","ix-pod01-esx06.stxt.media.int.ix","ix-pod01-esx07.stxt.media.int.ix","ix-pod01-esx08.stxt.media.int.ix","ix-pod01-esx09.stxt.media.int.ix","ix-pod01-esx10.stxt.media.int.ix","ix-pod01-esx11.stxt.media.int.ix","ix-pod01-esx12.stxt.media.int.ix","ix-pod01-esx13.stxt.media.int.ix","ix-pod01-esx14.stxt.media.int.ix","ix-pod01-esx15.stxt.media.int.ix","ix-pod01-esx16.stxt.media.int.ix","ix-pod01-esx17.stxt.media.int.ix","ix-pod01-esx18.stxt.media.int.ix","ix-pod01-esx19.stxt.media.int.ix","ix-pod01-esx20.stxt.media.int.ix","ix-pod01-esx21.stxt.media.int.ix","ix-pod01-esx22.stxt.media.int.ix","ix-pod01-esx23.stxt.media.int.ix","ix-pod01-esx24.stxt.media.int.ix","ix-pod01-esx25.stxt.media.int.ix","ix-srv-esx-001.stxt.media.int.ix","ix-srv-esx-002.stxt.media.int.ix","ix-srv-esx-003.stxt.media.int.ix","ix-srv-esx-004.stxt.media.int.ix","ix-mapod01-esx01.stxt.media.int.ix","ix-mapod01-esx02.stxt.media.int.ix"]
chk = /vmcount_MAX/
points = []

SCHEDULER.every '20m', :first_in => '5s' do
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

    points << { x: Time.now.to_i, y: sum}
    send_event('vmcount', value: sum)
  rescue => e
  end
end

