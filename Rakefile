require 'bundler/setup'
require 'yaml'
require_relative 'src/cr/steam'
require_relative 'src/cr/model/database'

# RUBY_ENV variable can be set to production or development
# don't forget your STEAM_API_KEY env variable!

namespace :db do
  desc 'populate database'
  task :init do
    abort('please set your steam api key') unless ENV['STEAM_API_KEY']
    boards = YAML.load_file('data/boards.yml')['boards']
    boards.each do |board|
      ChelshiaRocks::Leaderboard.leaderboard(board['id'], name: board['name'])
    end
  end
end
