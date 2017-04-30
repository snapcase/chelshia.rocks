class WebsiteController < ApplicationController
  get '/' do
    redirect to '/leaderboards/'
  end

  get '/about' do
    @title = "All About This Website"
    # haml :about
  end
end
