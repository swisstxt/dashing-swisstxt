require 'json'
require 'net/http'
require 'net/https'

url_nagiosbp = '/nagiosbp/cgi-bin/nagios-bp.cgi?outformat=json'

SCHEDULER.every '5s', :first_in => '3s' do |job|
  data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/nagiosbp/cgi-bin/nagios-bp.cgi?outformat=json",true,settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
  data = JSON.parse(data)
  response =  Stxtdashing.parse(data)

  sendData= Hash.new

  if response['err']=="OK" then
    text=""
  else
    if response['count']<4 then
      text="Check #{response['prob']}"
    else
      text="Check #{response['count']} BusinessProcesses!"
    end
  end

  sendData["title"]="Business Processes: "+response['err']
  sendData["text"]=text
  if response['err']=="CRITICAL" then
    sendData["status"] = "warning"
  elsif response['err']=="WARNING" then
    sendData["status"] = "danger"
  else
    sendData["status"] = "ok"
  end

  send_event('bp',sendData)
end
