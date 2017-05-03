class WebsiteController < ApplicationController
  get '/' do
    redirect to '/leaderboards/'
  end

  get '/about' do
    @title = "All About This Website"
    haml :about, layout: :main
  end

  ChelshiaRocks::Leaderboard.each do |lb|
    name = lb.name.delete("' ").downcase

    get "/#{name}" do
      redirect to "/leaderboards/#{lb.leaderboard_id}"
    end
  end
end
