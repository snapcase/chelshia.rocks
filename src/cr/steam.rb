require 'rest-client'
require 'xmlsimple'

module Steam
  module API
    BASE_URL = 'http://steamcommunity.com'

    module_function

    # get a user
    # @return [Hash]
    def user(steamid)
      get "profiles/#{steamid}?xml=1"
    end

    # get a leaderboard
    # @return [Hash]
    def leaderboard(appid, id, start = 1, _end = 20)
      get "stats/#{appid}/" \
          "leaderboards/#{id}?xml=1" \
          "&start=#{start}&end=#{_end}&t=#{Time.now.to_i}"
    end

    def self.get(path)
      response = RestClient.get "#{BASE_URL}/#{path}"
      XmlSimple.xml_in(response, keytosymbol: true, forcearray: false)
    end
  end
end
