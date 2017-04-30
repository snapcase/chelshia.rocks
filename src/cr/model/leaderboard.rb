module ChelshiaRocks
  # Steam App ID of Khimera: Destroy All Monster Girls
  KHIMERA_APP_ID = 467380

  class Leaderboard
    include NoBrainer::Document

    # ID of this leaderboards application
    field :app_id, type: String

    # Name of this leaderboard
    # @note This is not supplied by Steam::API, and must be provided if desired
    field :name, type: String

    # This leaderboard's steam ID
    field :leaderboard_id, type: String

    # The total number of entries available from Steam
    field :total_entries, type: Integer

    # Array containing the IDs of the latest entries for each rank
    field :latest_entries, type: Array

    # The name of this leaderboard
    field :name, type: String

    has_many :entrys
    has_many :users, through: :entrys

    # URL to this leaderboard's Steam page
    def url
      "#{Steam::API::BASE_URL}/stats/#{app_id}/leaderboards/#{leaderboard_id}"
    end

    # The most recent entries for this board
    # @return [Array<Entry>]
    def board
      latest_entries.map { |id| Entry.find id }
    end

    # Returns a user's entry for this leaderboard
    # @param data [String, Integer, User] the id or User object to look for
    # @return [User]
    def user(data)
      id = data.is_a?(User) ? data.id : data
      board.find { |e| e.user.steam_id == id.to_s }
    end

    # Fetches a leaderboard object from the database. If it isn't found,
    # a request will be made to cache it from Steam unless
    # `request` is `false`.
    # @param name [String] the name of this leaderboard
    def self.leaderboard(leaderboard_id, name: nil, app_id: KHIMERA_APP_ID, request: true)
      app_id = app_id.to_s
      leaderboard_id = leaderboard_id.to_s
      leaderboard = where(app_id: app_id, leaderboard_id: leaderboard_id).all.first
      return leaderboard if leaderboard
      return unless request

      from_hash Steam::API.leaderboard(app_id, leaderboard_id), name
    end

    # Refreshes this leaderboard's entries by making
    # an API request, or with the data provided.
    def refresh!(data = nil)
      data ||= Steam::API.leaderboard(app_id, leaderboard_id)[:entries][:entry]

      updated_ranks = []
      new_entries = []

      data.map do |e|
        new_entries << Entry.create(
          score: e[:score],
          rank: e[:rank],
          timestamp: Time.now,
          leaderboard: self,
          user: User.user(e[:steamid])
        )

        updated_ranks[entry.rank - 1] = entry.id
      end

      update(latest_entries: updated_ranks)

      new_entries.map { |e| e.user.update_score! }
    end

    # Creates a new Leaderboard from a Steam API leaderboard hash
    def self.from_hash(data, name = nil)
      new_board = create(
        app_id: data[:appid],
        leaderboard_id: data[:leaderboardid],
        total_entries: data[:totalleaderboardentries].to_i,
        latest_entries: [],
        name: name
      )

      new_board.refresh! data[:entries][:entry]

      new_board
    end
  end
end
