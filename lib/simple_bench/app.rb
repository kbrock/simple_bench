require 'sinatra'

module SimpleBench
  class App < Sinatra::Base
    # static files
    set :static, true
    set :public, File.expand_path('../app/public', __FILE__)

    # views
    set :views,  File.expand_path('../app/views', __FILE__) # set up the views dir
    
    # actions

    get '/' do
      # erb :'/index'
      erb :'/show'
    end
  end
end
