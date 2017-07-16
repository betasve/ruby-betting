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

    class << self
      def score(guesses, winners)
        bet_score = new(guesses, winners)
        bet_score.points
      end
    end

    def initialize(guesses, winners)
      @guesses = sanitize(guesses)
      @winners = sanitize(winners)
    end

    def points
      total_score = 0
      guesses.each_with_index do |guess, place|
        total_score += exact_hit = exact_hits(guess, place)
        total_score += top_5s(guess).to_i if exact_hit.zero?
      end

      total_score
    end

    private

    def sanitize(arr)
      validate(arr)
      # NOTE: Logically - one racer per bet
      # TODO: Fix some tests  that are failing because of this
      arr.uniq
    end

    def validate(arr)
      raise ArgumentError, 'Winners - not an array' unless arr.is_a? Array
      raise ArgumentError, 'Winners are empty' if arr.size.zero?
    end

    def exact_hits(guess, index)
      return SCORING[:exact_hit][index].to_i if winners[index] == guess
      0
    end

    def top_5s(guess)
      SCORING[:top_5] if winners.index(guess) && winners.index(guess) <= 4
    end
  end
end
