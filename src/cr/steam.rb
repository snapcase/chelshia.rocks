require 'rest-client'
require 'xmlsimple'
require 'json'

module Steam
  module API
    # URL of the official Steam API
    API_URL = 'https://api.steampowered.com'.freeze

    # URL of Steam's community site
    COMMUNITY_URL = 'https://steamcommunity.com'.freeze

    module_function

    # Generic GET request handler
    # @param route [String] the route to send a request to
    # @param params [Hash] querystring parameters
    # @param parser [Symbol] either :json or :xml will parse using those parsers. Any other value (nil) returns the raw response
    def get(route = '', params = {}, parser = :json)
      response = RestClient.get(route, params: params)

      return JSON.parse(response, symbolize_names: true) if parser == :json
      return XmlSimple.xml_in(response, keytosymbol: true, forcearray: false) if parser == :xml
      response
    end

    # Get one or more users by Steam ID
    # @param steam_id [Integer, String, Array<Integer, String>] One or more Steam ID's
    # @return [Array<Hash>]
    def user(steam_id)
      ids = steam_id.is_a?(Array) ? steam_id.join(',') : steam_id
      response = get "#{API_URL}/ISteamUser/GetPlayerSummaries/v0002/",
                     {
                       key: ENV['STEAM_API_KEY'],
                       steamids: ids
                     },
                     :json
      response[:response][:players]
    end

    # Get a leaderboard
    # @param app_id [Integer] ID of the Steam application
    # @param id [Integer] ID of the leaderboard
    # @param start [Integer] index start of paginated responses
    # @param _end [Integer] index end of paginated responses
    # @return [Hash]
    def leaderboard(app_id, id, index_start = 1, index_end = 100)
      get "#{COMMUNITY_URL}/stats/#{app_id}/leaderboards/#{id}",
          {
            xml: 1,
            start: index_start,
            end: index_end,
            t: Time.now.to_i
          },
          :xml
    end
  end
end
