require_relative 'spec_helper'
require_relative '../lib/race'

# rubocop:disable Metrics/BlockLength
RSpec.describe RaceBet::Race do
  let(:guesses) { %i(joe mary bob sheldon howard frank) }
  let(:first) { RaceBet::Race::SCORING[:exact_hit][0] }
  let(:second) { RaceBet::Race::SCORING[:exact_hit][1] }
  let(:third) { RaceBet::Race::SCORING[:exact_hit][2] }
  let(:fourth) { RaceBet::Race::SCORING[:exact_hit][3] }
  let(:fifth) { RaceBet::Race::SCORING[:exact_hit][4] }
  let(:misplaced) { RaceBet::Race::SCORING[:top_5] }

  def winner_place(n)
    (1..n + 1).to_a.map do |place|
      n != place ? "loser#{place}" : guesses[n - 1]
    end
  end

  def self.it_raises_for(method)
    context 'and the argument is not an array' do
      it do
        expect { subject.send(method, :jill) }.to raise_error(ArgumentError)
      end
    end

    context 'and the argument is an empty array' do
      it do
        expect { subject.send(method, []) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#score' do
    subject { described_class.score(guesses, winners) }

    context 'all guesses correct' do
      let(:guesses) { %i(joe mary bob) }
      let(:winners) { guesses }

      it 'calculates points respectively for correct guesses' do
        expect(subject).to eq(first + second + third)
      end
    end

    context 'no points for no correct guesses' do
      let(:winners) { %i(loser loser1) }

      it { expect(subject).to eq(0) }
    end

    context '15 points for first place' do
      let(:winners) { winner_place(1) }

      it { expect(subject).to eq(first) }
    end

    context '10 points for second place' do
      let(:winners) { winner_place(2) }

      it { expect(subject).to eq(second) }
    end

    context '5 points for third place' do
      let(:winners) { winner_place(3) }

      it { expect(subject).to eq(third) }
    end

    context '3 points for fourth place' do
      let(:winners) { winner_place(4) }

      it { expect(subject).to eq(fourth) }
    end

    context '1 point for fifth place' do
      let(:winners) { winner_place(5) }

      it { expect(subject).to eq(fifth) }
    end

    context 'gives one point for a correct guess in the wrong place' do
      let(:winners) do
        winners = winner_place(1)
        winners.unshift(winners.pop)
      end

      it { expect(subject).to eq(misplaced) }
    end

    context 'scores positional and misplaced guesses at the same time' do
      let(:winners) do
        winners = [guesses[0], :loser, :loser2, guesses[3], :loser3]
        winners[3], winners[4] = winners[4], winners[3]
        winners
      end

      it { expect(subject).to eq(first + misplaced) }
    end

    context 'README example' do
      let(:guesses) { %i(bob mark walter) }
      let(:winners) { %i(mark bob walter) }

      it { expect(subject).to eq(third + 2 * misplaced) }
    end
  end
  # rubocop:enable Metrics/BlockLength

  describe '#sanitize' do
    subject { described_class.new(guesses, guesses) }

    context 'when valid parameters' do
      it 'returns unique elements' do
        expect(subject.send(:sanitize, %i(jill jill jack)))
          .to eq(%i(jill jack))
      end
    end

    context 'when invalid parameters' do
      it_raises_for :sanitize
    end
  end

  describe '#validate' do
    subject { described_class.new(guesses, guesses) }
    it_raises_for :validate
  end

  describe '#exact_hits' do
    subject { described_class.new(guesses, winners) }
    let(:winners) { winner_place(1) }

    context 'when an exact hit' do
      it { expect(subject.send(:exact_hits, guesses[0], 0)).to eq first }
    end

    context 'when not an exact hit' do
      it { expect(subject.send(:exact_hits, guesses[0], 2)).to be_zero }
    end
  end

  describe '#in_top_5' do
    subject { described_class.new(guesses, winners) }
    let(:winners) { winner_place(4) }

    context 'when match is in top 5' do
      it { expect(subject.send(:in_top_5, guesses[3])).to eq misplaced }
    end

    context 'when match is not in top 5' do
      it { expect(subject.send(:in_top_5, guesses[5])).to be_zero }
    end
  end
end
