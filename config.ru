require 'sinatra/base'

require_relative 'src/cr'

map('/') { run WebsiteController }
map('/leaderboards') { run LeaderboardController }
map('/users') { run UserController }
