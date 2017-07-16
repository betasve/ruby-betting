require_relative 'spec_helper'
require_relative '../lib/race'

RSpec.describe RaceBet::Race do # rubocop:disable Metrics/BlockLength
  let(:guesses) { %i[joe mary bob sheldon howard frank] }

  subject { described_class.score(guesses, winners) }

  context 'all guesses correct' do
    let(:guesses) { [1, 2, 3] }
    let(:winners) { guesses }

    it 'calculates 15, 10, 5 points respectively for correct guesses' do
      expect(subject).to eq(15 + 10 + 5)
    end
  end

  context 'no points for no correct guesses' do
    let(:winners) { (0..guesses.size - 1).to_a }

    it { expect(subject).to eq(0) }
  end

  context '15 points for first place' do
    let(:winners) { [guesses[0], :loser, :loser] }

    it { expect(subject).to eq(15) }
  end

  context '10 points for second place' do
    let(:winners) { [:loser, guesses[1], :loser] }

    it { expect(subject).to eq(10) }
  end

  context '5 points for third place' do
    let(:winners) { [:loser, :loser, guesses[2]] }

    it { expect(subject).to eq(5) }
  end

  context '3 points for fourth place' do
    let(:winners) { [:loser, :loser, :loser, guesses[3]] }

    it { expect(subject).to eq(3) }
  end

  # NOTE: This one is passing because bet is in top 5 not bause the 5th place
  context '1 point for fifth place' do
    let(:winners) { [:loser, :loser, :loser, :loser, guesses[4]] }

    it { expect(subject).to eq(1) }
  end

  context 'gives one point for a correct guess in the wrong place' do
    let(:winners) do
      winners = [guesses[0], :loser, :loser]
      winners.unshift(winners.pop)
      winners
    end

    it { expect(subject).to eq(1) }
  end

  context 'scores positional and misplaced guesses at the same time' do
    let(:winners) do
      winners = [guesses[0], :loser, :loser, guesses[3], :loser]
      winners[3], winners[4] = winners[4], winners[3]
      winners
    end
    it { expect(subject).to eq(15 + 1) }
  end

  context 'README example' do
    let(:guesses) { %i[bob mark walter] }
    let(:winners) { %i[mark bob walter] }

    it { expect(subject).to eq(5 + 1 + 1) }
  end
end
