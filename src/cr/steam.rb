require 'rest-client'
require 'xmlsimple'
require 'json'

module Steam
  module API
    module_function

    # Get one or more users by Steam ID
    # @param steam_id [Integer, String, Array<Integer, String>] One or more Steam ID's
    # @return [Array<Hash>]
    def user(steam_id)
      ids = steam_id.is_a?(Array) ? steam_id.join(',') : steam_id
      response =
        RestClient.get "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/",
          params: {
            key: ENV['STEAM_API_KEY'],
            steamids: ids
          }
        json = JSON.parse(response, symbolize_names: true)
        json[:response][:players]
    end

    # Get a leaderboard
    # @param app_id [Integer] ID of the Steam application
    # @param id [Integer] ID of the leaderboard
    # @param start [Integer] index start of paginated responses
    # @param _end [Integer] index end of paginated responses
    # @return [Hash]
    def leaderboard(app_id, id, index_start = 1, index_end = 100)
      response =
        RestClient.get "http://steamcommunity.com/stats/#{app_id}/leaderboards/#{id}",
          params: {
            xml: 1,
            start: index_start,
            end: index_end,
            t: Time.now.to_i
        }
      XmlSimple.xml_in(response, keytosymbol: true, forcearray: false)
    end
  end
end
