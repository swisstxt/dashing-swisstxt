require 'json'
require 'net/http'
require 'net/https'


SCHEDULER.every '60s', :first_in => '5s' do |job|
  begin
    data = Stxtdashing.fetch_http(settings.config["zendesk"]["url"],settings.config["zendesk"]["path"],settings.config["zendesk"]["ssl"],settings.config["zendesk"]["user"],settings.config["zendesk"]["pw"])

    data = JSON.parse(data)
    ticket_count = data['count']
    status = if (ticket_count<1) then "ok" else "danger" end

    send_event("zendesk",{title: "New Tickets", status: status, text: ticket_count})
  
  end
end
