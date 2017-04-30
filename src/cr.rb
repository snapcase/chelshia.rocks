require_relative 'cr/version'
require_relative 'cr/steam'
require_relative 'cr/model/database'

require_relative 'cr/controller/leaderboard_controller'
require_relative 'cr/controller/user_controller'

binding.pry if $0 == __FILE__
