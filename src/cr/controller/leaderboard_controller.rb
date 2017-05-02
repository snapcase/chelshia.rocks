class LeaderboardController < ApplicationController
  get '/' do
    @leaderboards = ChelshiaRocks::Leaderboard.to_a
    @users = ChelshiaRocks::User.order_by(score: :desc).limit(20).to_a
    haml :index
  end

  get '/:id' do
    @leaderboard = ChelshiaRocks::Leaderboard.leaderboard(params['id'], request: false)
    haml :leaderboard
  end

  get '/:board_id/:user_id' do
    @leaderboard = ChelshiaRocks::Leaderboard.leaderboard(params['board_id'], request: false)
    @user = ChelshiaRocks::User.user(params['user_id'], request: false)
    @entries = @leaderboard.entrys.where(user: @user).to_a

    haml :leaderboard_user
  end
end
