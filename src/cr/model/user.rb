require_relative './score'

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
    has_many :leaderboards, through: :entrys

    # URL to this user's steam profile
    def profile_url
      "#{Steam::API::BASE_URL}/profiles/#{steam_id}"
    end

    # Update this user's score
    def update_score!
      value = leaderboards.map do |l|
        next 0 unless l.scored?
        Score.value l.user(self.steam_id)&.rank || 0
      end.reduce(:+)

      update(score: value)

      value
    end

    # Update's this users Steam data
    def update!
      data = Steam::API.user(steam_id).first
      update(
        name: data[:personaname],
        avatar_url: data[:avatarfull]
      )
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

      from_array Steam::API.user(steam_id)[:response][:players].first
    end

    # Creates new Users from the Steam API user hash
    # @param data [Array<Hash>] The user objects passed from the json array
    def self.from_array(data)
      data.each do |user|
        create(
          steam_id: user[:steamid],
          name: user[:personaname],
          avatar_url: user[:avatarfull],
          created_at: Time.now
        )
      end
    end
  end
end
