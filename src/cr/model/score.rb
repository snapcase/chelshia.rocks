module ChelshiaRocks
  # This module describes the rules in scoring ranks across leaderboards.
  module Score
    # The value of each rank
    RANK_VALUES = Array.new(20) { |i| ((((i + 1) * i) / 380.0) * 100).round }.reverse

    module_function

    # Appraises a rank
    def value(rank)
      RANK_VALUES[rank - 1] || 0
    end
  end
end
