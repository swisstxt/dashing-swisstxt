require 'net/http'
require 'json'

rapid_view_id = 97

SCHEDULER.every '30m', :first_in => '5s' do
  # authenticate
  http             = Net::HTTP.new('jira.swisstxt.ch', 443)
  http.use_ssl     = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new('/rest/auth/latest/session')
  request.content_type = 'application/json'
  request.body = '{"username": "%s", "password": "%s"}' % [settings.config["jira"]["user"], settings.config["jira"]["pw"]]

  response = http.request(request);
  session  = JSON.parse(response.body)['session']

  if session['name'] == 'JSESSIONID' then
  session_cookie = {'COOKIE' => 'JSESSIONID=%s' % session['value']}

    #get actual sprint
    spr_url = '/rest/greenhopper/1.0/sprint/picker?excludeCompleted=true&maxResults=10000'
    spr_req = Net::HTTP::Get.new(spr_url, session_cookie)
    spr_res = http.request(spr_req)
    spr_rep = JSON.parse(spr_res.body)
    test = spr_rep["allMatches"].select{|a| if(a["stateKey"]=="ACTIVE" && a["boardName"]=="Managed Services") then a end}
    sprint_id = test[0]["id"]

    url = '/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=%d&sprintId=%d' % [rapid_view_id, sprint_id]

    request = Net::HTTP::Get.new(url, session_cookie)
    response = http.request(request)
    report   = JSON.parse(response.body)

    if report['contents']

      all_issues  = report['contents']['completedIssues']
      all_issues += report['contents']['incompletedIssues']
      
      open = ['Open', 'Reopened']
      closed = ['Closed']
      tod = ['In Progress']

      c_open = all_issues.select{ |a| open.include?(a["statusName"])}.count
      c_closed = all_issues.select{ |a| closed.include?(a["statusName"])}.count
      c_tod = all_issues.select{ |a| tod.include?(a["statusName"])}.count


      send_event('jira_ms', {
        sprint: report['sprint']['name'],
        not_started: c_open,
        in_progress: c_tod,
        done: c_closed
      })
    end
  end
end
