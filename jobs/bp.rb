require 'json'
require 'net/http'
require 'net/https'

url_nagiosbp = '/nagiosbp/cgi-bin/nagios-bp.cgi?outformat=json'

SCHEDULER.every '5s', :first_in => '3s' do |job|
  begin
    data = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/nagiosbp/cgi-bin/nagios-bp.cgi?outformat=json",settings.config["nagios"]["ssl"],settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
    data = JSON.parse(data)
    response =  Stxtdashing.parse(data)

    sendData= Hash.new

    if response['err']=="OK" then
      text=""
    else
      sleep(25)
      updating = Stxtdashing.fetch_http(settings.config["nagios"]["url"],"/icinga/cgi-bin/tac.cgi",settings.config["nagios"]["ssl"],settings.config["nagios"]["user"],settings.config["nagios"]["pw"])
      exit 0 if updating.include? "OUTDATED"
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
  rescue => e
  end
end
