require 'rest-client'
require 'xmlsimple'

module Steam
  module API
    BASE_URL = 'http://steamcommunity.com'

    module_function

    # get a user
    # @return [Hash]
    def user(steamid)
      get "profiles/#{steamid}"
    end

    # get a leaderboard
    # @return [Hash]
    def leaderboard(appid, id, start = 1, _end = 20)
      get "stats/#{appid}/leaderboards/#{id}",
          start: start,
          end: _end,
          t: Time.now
    end

    def self.get(path = '', params = {})
      params[:xml] = 1
      response = RestClient.get "#{BASE_URL}/#{path}", params: params
      XmlSimple.xml_in(response, keytosymbol: true, forcearray: false)
    end
  end
end
