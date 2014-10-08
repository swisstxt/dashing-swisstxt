require 'json'
require 'net/http'
require 'net/https'


SCHEDULER.every '10s', :first_in => '3s' do |job|
  begin
    data = Stxtdashing.fetch_http(settings.config["zendesk"]["url"],settings.config["zendesk"]["path"],settings.config["zendesk"]["ssl"],settings.config["zendesk"]["user"],settings.config["zendesk"]["pw"])

    data = JSON.parse(data)
    ticket_count = data['count']
    icon = if (ticket_count<1) then "thumbs-up" else "thumbs-down" end

    send_event("zendesk",{title: "New Tickets", icon: icon, text: ticket_count})
  
  end
end
  
