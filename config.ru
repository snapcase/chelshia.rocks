require 'sinatra/base'
require 'haml'

require_relative 'src/cr'

map('/leaderboards') { run LeaderboardController }
map('/users') { run UserController }
