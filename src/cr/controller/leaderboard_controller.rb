class LeaderboardController < ApplicationController
  get '/' do
    @leaderboards = ChelshiaRocks::Leaderboard.to_a
    @users = ChelshiaRocks::User.order_by(score: :desc).limit(20).to_a
    @title = 'Leaderboards'
    haml :index, layout: :main
  end

  get '/:id' do
    @leaderboard = ChelshiaRocks::Leaderboard.leaderboard(params['id'], request: false)
    halt(404) unless @leaderboard

    @title = @leaderboard.name
    haml :leaderboard, layout: :main
  end

  get '/:board_id/:user_id' do
    @leaderboard = ChelshiaRocks::Leaderboard.leaderboard(params['board_id'], request: false)
    @user = ChelshiaRocks::User.user(params['user_id'], request: false)

    halt(404) unless @leaderboard && @user

    @entries = @leaderboard.entrys.where(user: @user).to_a

    @title = "#{@user.name}'s #{@leaderboard.name} scores"
    haml :leaderboard_user, layout: :main
  end
end
