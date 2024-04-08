require 'rails_helper'

RSpec.describe Game, type: :model do
  describe '#score' do
    let(:game) { Game.create }

    it 'calculates the score of one frame has strike in a game' do
      game.rolls.create(pins_knocked_down: 10)

      game.rolls.create(pins_knocked_down: 3)
      game.rolls.create(pins_knocked_down: 4)

      frame_score = game.calculate_score
      total_score = frame_score.sum { |frame| frame.values.first }

      expect(frame_score.first.values.first).to eq(17)
      expect(frame_score.second.values.first).to eq(7)
      expect(total_score).to eq(24)
    end

    it 'calculates the score of one frame has spare in a game' do
      game.rolls.create(pins_knocked_down: 0)
      game.rolls.create(pins_knocked_down: 10)

      game.rolls.create(pins_knocked_down: 5)
      game.rolls.create(pins_knocked_down: 2)

      frame_score = game.calculate_score
      total_score = frame_score.sum { |frame| frame.values.first }

      expect(frame_score.first.values.first).to eq(15)
      expect(frame_score.second.values.first).to eq(7)
      expect(total_score).to eq(22)
    end

    it 'calculates the score of four frames in a game' do
      game.rolls.create(pins_knocked_down: 10)

      game.rolls.create(pins_knocked_down: 3)
      game.rolls.create(pins_knocked_down: 4)

      game.rolls.create(pins_knocked_down: 6)
      game.rolls.create(pins_knocked_down: 2)

      game.rolls.create(pins_knocked_down: 8)
      game.rolls.create(pins_knocked_down: 0)

      frame_score = game.calculate_score
      total_score = frame_score.sum { |frame| frame.values.first }

      expect(frame_score.first.values.first).to eq(17)
      expect(frame_score.second.values.first).to eq(7)
      expect(frame_score.third.values.first).to eq(8)
      expect(frame_score.fourth.values.first).to eq(8)
      expect(total_score).to eq(40)
    end
  end
end
