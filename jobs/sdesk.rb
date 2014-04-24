# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'viewpoint'
require 'time'
include Viewpoint::EWS

rooms = Hash.new
rooms["SiZi1"] = Hash.new
rooms["SiZi2"] = Hash.new
rooms["SiZi3"] = Hash.new
rooms["SiZi4"] = Hash.new

SCHEDULER.every '2h', :first_in => '45s' do |job|
  
  t = Time.now
  start_time = Time.new(t.year,t.month,t.day,0,0,0)
  end_time = Time.new(t.year,t.month,t.day,23,59,59)
  result = []

  cli = Viewpoint::EWSClient.new settings.config["ews"]["url"], settings.config["ews"]["user"], settings.config["ews"]["pw"], http_opts: {ssl_verify_mode: 0}
  cli.set_time_zone "W. Europe Standard Time"
    events = cli.get_user_availability(["servicedesk@swisstxt.ch"], start_time: start_time.iso8601, end_time: end_time.iso8601, requested_view: :detailed).calendar_event_array
    events.each do |ev|
      date_start = if(Time.parse(cli.event_start_time(ev))<start_time) then start_time.strftime '%d/%m' else Time.parse(cli.event_start_time(ev)).strftime '%d/%m' end
      time_start = if(Time.parse(cli.event_start_time(ev))<start_time) then start_time.strftime '%H:%M' else Time.parse(cli.event_start_time(ev)).strftime '%H:%M' end
      time_start = if(time_start=="00:00") then "All day" else time_start end
      pikett = if(cli.event_name(ev)[0..5]=="Pikett") then true else false end
      result << { date: date_start, time: time_start, datetime: Time.parse(cli.event_start_time(ev)).iso8601(0),title: cli.event_name(ev).tr(?",?'),pikett: pikett }
    end
  send_event("timeline",{events: result})
end
