module RaceBet
  # :nodoc:
  class Race
    attr_reader :guesses, :winners

    SCORING = {
      exact_hit: {
        0 => 15,
        1 => 10,
        2 => 5,
        3 => 3,
        4 => 1
      },
      top_5: 1
    }.freeze

    FIFTH = 4
    NOT_AN_ARRAY = 'Winners is not an array'.freeze
    EMPTY_ARRAY = 'Winners array is empty'.freeze

    class << self
      def score(guesses, winners)
        bet_score = new(guesses, winners)
        bet_score.calculate_points
      end
    end

    def initialize(guesses, winners)
      @guesses = sanitize(guesses)
      @winners = sanitize(winners)
    end

    def calculate_points
      total_score = 0
      guesses.each_with_index do |guess, place|
        total_score += exact_hit = exact_hits(guess, place)
        total_score += in_top_5(guess) if exact_hit.zero?
      end

      total_score
    end

    private

    def sanitize(arr)
      validate(arr)
      # NOTE: You can't place multiple bets for one racer
      arr.uniq
    end

    def validate(arr)
      raise ArgumentError, NOT_AN_ARRAY unless arr.is_a? Array
      raise ArgumentError, EMPTY_ARRAY if arr.size.zero?
    end

    def exact_hits(guess, index)
      return SCORING[:exact_hit][index].to_i if winners[index] == guess
      0
    end

    def in_top_5(guess)
      return 0 unless winners.index(guess)&.send(:<=, FIFTH)
      SCORING[:top_5]
    end
  end
end
