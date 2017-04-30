class LeaderboardController < ApplicationController
  get '/' do
    haml :index
  end

  get '/:id' do
    "Leaderboard #{params[:id]} Show"
  end
end
