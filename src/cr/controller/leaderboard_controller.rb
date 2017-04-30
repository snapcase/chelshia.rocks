class LeaderboardController < Sinatra::Base

  get '/' do
    "Leaderboards Index"
    haml :index
  end

  get '/:id' do
    "Leaderboard #{params[:id]} Show"
  end

end
