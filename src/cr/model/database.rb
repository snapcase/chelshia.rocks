require 'nobrainer'

NoBrainer.configure do |config|
  config.app_name = %{chelshia}
end

require_relative './user.rb'

NoBrainer.sync_indexes
