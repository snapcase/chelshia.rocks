module ChelshiaRocks
  class User
    include NoBrainer::Document

    # Steam ID for this user
    field :steam_id, type: String

    # Name of this user
    field :name, type: String

    # URL to this user's avatar
    field :avatar_url, type: String

    # Time this user was created
    field :created_at, type: Time

    # This user's game-wide score
    field :score, type: Integer, default: 0

    has_many :entrys

    # URL to this user's steam profile
    def profile_url
      "#{Steam::API::BASE_URL}/profiles/#{steam_id}"
    end

    # Fetches a user object from the database. If it isn't found,
    # a request will be made to cache it from Steam unless
    # `request` is `false`.
    # @param steam_id [String, #to_s] steam ID
    # @param request [true, false] whether to fetch this user from the API if it doesn't exist
    def self.user(steam_id, request: true)
      user = where(steam_id: steam_id.to_s).first
      return user if user
      return unless request

      from_hash Steam::API.user(steam_id)
    end

    # Creates a new User from a Steam API user hash
    def self.from_hash(data)
      create(
        steam_id: data[:steamid64],
        name: data[:steamid],
        avatar_url: data[:avatarfull],
        created_at: Time.now
      )
    end
  end
end
