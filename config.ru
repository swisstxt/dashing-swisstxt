require 'dashing'
require './lib/functions'
require 'yaml'
require 'ipaddr'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :config,  Stxtdashing.load_configuration('./config.yml')


  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
    def authorized?
      reqIP = IPAddr.new(request.ip)
      if(!settings.config['ip'].select{|ip| if(IPAddr.new(ip).include?(reqIP)) then ip end }.empty?) then
        true
      else
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [settings.config["dashing"]["user"], settings.config["dashing"]["pw"]]
      end
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
