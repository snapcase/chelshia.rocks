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
    field :latest_entries

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

    # Fetches a leaderboard object from the database. If it isn't found,
    # a request will be made to cache it from Steam unless
    # `request` is `false`.
    # @param name [String] the name of this leaderboard
    def self.leaderboard(leaderboard_id, app_id: KHIMERA_APP_ID, request: true)
      app_id = app_id.to_s
      leaderboard_id = leaderboard_id.to_s
      leaderboard = where(app_id: app_id, leaderboard_id: leaderboard_id).all.first
      return leaderboard if leaderboard
      return unless request

      from_hash Steam::API.leaderboard(app_id, leaderboard_id)
    end

    # Refreshes this leaderboard's entries by making
    # an API request, or with the data provided.
    def refresh!(data = nil)
      data ||= Steam::API.leaderboard(app_id, leaderboard_id)[:entries][:entry]

      updated_ranks = []

      data.map do |e|
        entry = Entry.create(
          score: e[:score],
          rank: e[:rank],
          timestamp: Time.now,
          leaderboard: self,
          user: User.user(e[:steamid])
        )

        updated_ranks[entry.rank - 1] = entry.id
      end

      update(latest_entries: updated_ranks)
    end

    # Creates a new Leaderboard from a Steam API leaderboard hash
    def self.from_hash(data)
      new_board = create(
        app_id: data[:appid],
        leaderboard_id: data[:leaderboardid],
        total_entries: data[:totalleaderboardentries].to_i,
        latest_entries: []
      )

      new_board.refresh! data[:entries][:entry]

      new_board
    end
  end
end
