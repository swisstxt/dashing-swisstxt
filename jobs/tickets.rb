require 'tiny_tds'
require 'json'

query = "SELECT FullName as label, cntr as value FROM [_STXT_SP_Container].[dbo].[TXP_OpenByOwner] order by value desc"


SCHEDULER.every '10m', :first_in => '20s' do
        res = Stxtdashing.sql_exec(settings.config['sql']['instance'],settings.config['sql']['user'],settings.config['sql']['pw'],query)
        items = []
        res.each do |r|
	  label = r["label"].split("(")[1].split(")")[0]
          items << { label: label, value: r["value"]}
        end

  send_event('tickets', { items: items })
end
