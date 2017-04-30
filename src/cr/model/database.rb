require 'nobrainer'

NoBrainer.configure do |config|
  config.app_name = %{chelshia}
end

require_relative './user'
require_relative './leaderboard'
require_relative './entry'

NoBrainer.sync_indexes
