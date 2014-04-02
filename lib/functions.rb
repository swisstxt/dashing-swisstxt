require 'yaml'

module Stxtdashing
  def self.load_configuration(config_file)
    unless File.exists?(config_file)
      puts "Configuration file #{config_file} not found.", :red
      exit 1
    end
    begin
      config = YAML::load(IO.read(config_file))
    rescue
      puts "Can't load configuration from file #{config_file}."
      exit 1
    end
    return config
  end

  def self.fetch_http(server,path,ssl=false,username=nil,password=nil)
    if ssl then port=443 else port=80 end
    Retriable.retriable do
      http = Net::HTTP.new(server,port)
      req = Net::HTTP::Get.new(path)
      if ssl then
	http.use_ssl = true
	req.basic_auth username, password
      end
      response = http.request(req)
      return response.body
    end
  end

  def self.sql_exec(instance, user, pw, query)
    client = TinyTds::Client.new(:username => user, :password => pw, :dataserver => instance)
    res = client.execute(query)
    #client.close
    return res
  end

  def self.parse(data)
    cont = Hash.new
    raw = Hash.new
    prob = Array.new
    err = 0
    data['business_processes'].each { |key,val|
    if(val['display_prio'].to_i==1)
      case val['hardstate']
      when "CRITICAL"
	err = err+30
	prob.push(key)
      when "WARNING"
	err = err+20
	prob.push(key)
      when "UNKNOWN"
	err = err+10
	prob.push(key)
      end
     raw[key]=val['hardstate']
    end
    }
    case
      when err<10 then cont['err']="OK"
      when err<20 then cont['err']="UNKNOWN"
      when err<30 then cont['err']="WARNING"
      when err>=30 then cont['err']="CRITICAL"
    end
    cont['raw'] = raw
    cont['count']=prob.size
    cont['prob']=prob.join(", ")
    return cont
  end
end
