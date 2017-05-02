class LeaderboardController < ApplicationController
  get '/' do
    @leaderboards = ChelshiaRocks::Leaderboard.to_a
    haml :index
  end

  get '/:id' do
    @leaderboard = ChelshiaRocks::Leaderboard.leaderboard(params['id'])
    haml :leaderboard
  end
end
