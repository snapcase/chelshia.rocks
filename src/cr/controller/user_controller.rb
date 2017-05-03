class UserController < ApplicationController
  get '/' do
    "Users Index"
  end

  get '/:id' do
    @user = ChelshiaRocks::User.user(params['id'])
    halt(404) unless @user

    @boards = user.leaderboards

    haml :user
  end
end
