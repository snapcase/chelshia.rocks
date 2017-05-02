module ChelshiaRocks
  class Entry
    include NoBrainer::Document

    # This entry's score
    field :score, type: String

    # This entry's rank, at the time of creation
    field :rank, type: Integer

    # When this entry was logged
    field :timestamp, type: Time

    belongs_to :user, index: true
    belongs_to :leaderboard, index: true

    # Hook to update user's score after creation
    after_create { user.update_score! }

    # Return's this entry's score as a formatted time string
    def time_str
      Time.at(score[0..-4].to_f + score[-3..-1].to_f / 1000)
          .strftime("%M:%S.%L")
    end

    # Alias for checking if an entry is older
    # than a given time
    def older_than?(time)
      time > timestamp
    end

    # Destroys any records older than a given time
    def self.prune!(time)
      to_a.each do |e|
        e.destroy if e.older_than? time
      end
    end
  end
end
