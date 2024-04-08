# == Schema Information
#
# Table name: rolls
#
#  id                      :integer          not null, primary key
#  game_id                 :integer
#  pins_knocked_down       :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class Roll < ApplicationRecord
  belongs_to :game

  validate :game_must_be_running
  validates :pins_knocked_down, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10
  }
  after_create :update_game_status
  after_create_commit :broadcast_game_score

  def game_must_be_running
    case game.status
    when 'completed'
      errors.add(:base, 'Game is already completed')
    when 'closed'
      errors.add(:base, 'Game is closed')
    end
  end

  def update_game_status
    rolls_count = game.rolls.count
    if rolls_count == 20 || (rolls_count == 21 && game.last_frame_pins >= 10)
      game.completed!
    elsif game.started?
      game.running!
    end
  end

  def broadcast_game_score
    ActionCable.server.broadcast("game_channel_#{game.id}",
                                 { score: game.calculate_score, status: game.status })
  end
end
