# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
require 'viewpoint'
require 'time'
include Viewpoint::EWS

rooms = Hash.new
rooms["SiZi1"] = Hash.new
rooms["SiZi2"] = Hash.new
rooms["SiZi3"] = Hash.new
rooms["SiZi4"] = Hash.new

SCHEDULER.every '1m', :first_in => '2s' do |job|
  
  start_time = Time.now.iso8601
  end_time = (Time.now + 7200).iso8601

  cli = Viewpoint::EWSClient.new settings.config["ews"]["url"], settings.config["ews"]["user"], settings.config["ews"]["pw"], http_opts: {ssl_verify_mode: 0}
  cli.set_time_zone "W. Europe Standard Time"
  rooms.each do |k,v|
    events = cli.get_user_availability(["#{k}@swisstxt.ch"], start_time: start_time, end_time: end_time, requested_view: :detailed).calendar_event_array
    res = events.empty? rescue true
    unless res
      if (Time.parse(cli.event_start_time(events[0]))>Time.now) then nownext = "(next)" else nownext = "(now)" end
      t_start = Time.parse(cli.event_start_time(events[0])).strftime '%H:%M'
      t_end = Time.parse(cli.event_end_time(events[0])).strftime '%H:%M'
      data={"type"=>cli.event_busy_type(events[0]),
      "time"=>"#{t_start} - #{t_end}",
      "event_name"=>cli.event_name(events[0]),
      "nownext"=>nownext}
      send_event(k,data)
    else
      send_event(k,{"type"=>"","time"=>"","event_name"=>"","nownext"=>""})
    end
  end
end
