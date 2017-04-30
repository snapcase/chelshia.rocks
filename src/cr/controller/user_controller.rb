class UserController < ApplicationController
  get '/' do
    "Users Index"
  end

  get '/:id' do
    "Users #{params[:id]} Show"
  end

end
