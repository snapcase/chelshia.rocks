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

    # The name of this leaderboard
    field :name, type: String

    # Whether this leaderboard counts towards its player's scores
    field :scored, type: Boolean, default: true

    # Timestamp of last update
    field :last_updated, type: Time

    has_many :entrys
    has_many :users, through: :entrys

    # URL to this leaderboard's Steam page
    def url
      "#{Steam::API::BASE_URL}/stats/#{app_id}/leaderboards/#{leaderboard_id}"
    end

    # The most recent entries for this board
    # @return [Array<Entry>]
    def board
      users.to_a.map { |u| u.latest_on(self) }.sort_by(&:score)
    end

    # Returns a user's entry for this leaderboard
    # @param data [String, Integer, User] the id or User object to look for
    # @return [User]
    def user(data)
      id = data.is_a?(User) ? data.steam_id : data
      # TODO: Will not work until #board is reimplemented
      board.find { |e| e.user.steam_id == id.to_s }
    end

    # Fetches a leaderboard object from the database. If it isn't found,
    # a request will be made to cache it from Steam unless
    # `request` is `false`.
    # @param name [String] the name of this leaderboard
    def self.leaderboard(leaderboard_id, name: nil, scored: true, app_id: KHIMERA_APP_ID, request: true)
      app_id = app_id.to_s
      leaderboard_id = leaderboard_id.to_s
      leaderboard = where(app_id: app_id, leaderboard_id: leaderboard_id).all.first
      return leaderboard if leaderboard
      return unless request

      from_hash Steam::API.leaderboard(app_id, leaderboard_id), name, scored
    end

    # Refreshes this leaderboard's entries by making
    # an API request, or with the data provided.
    def refresh!(data = nil)
      update_time = Time.now

      data ||= Steam::API.leaderboard(app_id, leaderboard_id)[:entries][:entry]
      
      user_ids = data.map { |e| e[:steamid] }.select { |id| User.user(id, request: false).nil? }
      User.from_array Steam::API.user(user_ids) if user_ids.any?

      data.each do |e|
        this_user = User.user(e[:steamid])
        next unless entrys.where(user: this_user, time: e[:score]).count.zero?

        Entry.create(
          user: this_user,
          rank: e[:rank],
          leaderboard: self,
          time: e[:score],
          timestamp: update_time
        )
      end

      update(last_updated: update_time)
    end

    # Helper to refresh all active boards
    def self.refresh_all!
      to_a.map(&:refresh!)
    end

    # Creates a new Leaderboard from a Steam API leaderboard hash
    def self.from_hash(data, name = nil, scored = true)
      new_board = create(
        app_id: data[:appid],
        leaderboard_id: data[:leaderboardid],
        total_entries: data[:totalleaderboardentries].to_i,
        name: name,
        scored: scored
      )

      new_board.refresh! data[:entries][:entry]

      new_board
    end
  end
end
