require 'tiny_tds'
require 'json'

query = "SELECT Escalated FROM [_STXT_SP_Container].[dbo].[TXP_Escalated]"

val = 0
SCHEDULER.every '1m', :first_in => '4s' do
	res = Stxtdashing.sql_exec(settings.config['sql']['instance'],settings.config['sql']['user'],settings.config['sql']['pw'],query)

	res.each do |v|
	  val=v["Escalated"]
	end

  send_event('escalated', { title: "Escalated Tickets", text: val })
end
