require 'dashing'
require './lib/functions'
require 'yaml'


configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :config,  Stxtdashing.load_configuration('./config.yml')


  helpers do
    def protected!
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
