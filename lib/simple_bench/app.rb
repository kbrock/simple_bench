require 'sinatra'
require 'json'

module SimpleBench
  class App < Sinatra::Base
    # static files
    set :static, true
    set :public_dir, File.expand_path('../app/public', __FILE__)

    # views
    set :views,  File.expand_path('../app/views', __FILE__) # set up the views dir
    
    # actions

    %w(/index.html /).each do |url|
      get url do
        results = database_report('HEAD').grouped_metrics
        erb :'/show', :locals => { :results => results }
      end
    end

    get '/:sha.json' do
      content_type 'text/json'
      results = database_report(params['sha']).grouped_metrics
      erb :'show_json', :locals => { :results => results }
    end

    # controller helpers
    def database_report(sha)
      DatabaseReport.new("temple.db", sha, Time.now)
    end
  end
end
