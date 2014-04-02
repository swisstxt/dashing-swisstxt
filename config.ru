require 'dashing'
require './lib/functions'
require 'yaml'
require 'redis-objects'


configure do
#Redis.current = Redis.new(:host => '127.0.0.1',:port => 6379)
#  set :history, Redis::HashKey.new('dashing-hash')

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

$firstrun = Hash.new

run Sinatra::Application
