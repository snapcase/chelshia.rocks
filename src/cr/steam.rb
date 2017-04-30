require 'rest-client'
require 'xmlsimple'

module Steam
  module API
    BASE_URL = 'http://steamcommunity.com'

    module_function

    # Get a user
    # @param [steam_id] the steam ID of the user
    # @return [Hash]
    def user(steam_id)
      get "profiles/#{steam_id}"
    end

    # Get a leaderboard
    # @param app_id [Integer] ID of the Steam application
    # @param id [Integer] ID of the leaderboard
    # @param start [Integer] index start of paginated responses
    # @param _end [Integer] index end of paginated responses
    # @return [Hash]
    def leaderboard(appid, id, start = 1, _end = 20)
      get "stats/#{appid}/leaderboards/#{id}",
          start: start,
          end: _end,
          t: Time.now.to_i
    end

    def self.get(path = '', params = {})
      params[:xml] = 1
      response = RestClient.get "#{BASE_URL}/#{path}", params: params
      XmlSimple.xml_in(response, keytosymbol: true, forcearray: false)
    end
  end
end
