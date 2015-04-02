require 'json'
require 'net/http'
require 'net/https'


SCHEDULER.every '60s', :first_in => '5s' do |job|
  begin
  #Swisstxt requests
    data = Stxtdashing.fetch_http(settings.config["zendesk"]["url"],settings.config["zendesk"]["path"],settings.config["zendesk"]["ssl"],settings.config["zendesk"]["user"],settings.config["zendesk"]["pw"])

    data = JSON.parse(data)
    ticket_count = data['count']
    status = if (ticket_count<1) then "ok" else "danger" end

    send_event("zendesk",{title: "New Tickets", status: status, text: ticket_count})
    
  #Mediahub requests  
    data = Stxtdashing.fetch_http(settings.config["mediahub"]["url"],settings.config["mediahub"]["path"],settings.config["mediahub"]["ssl"],settings.config["mediahub"]["user"],settings.config["mediahub"]["pw"])

    data = JSON.parse(data)
    
    ticket_count = data['count']
    status = if (ticket_count<1) then "ok" else "danger" end
  
    send_event("mediahub",{title: "New Mediahub Request", status: status, text: ticket_count})
  
  end
end
