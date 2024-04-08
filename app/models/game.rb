# == Schema Information
#
# Table name: games
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status                  :string           default("started"), not null
#
class Game < ApplicationRecord
  has_many :rolls, -> { order(id: :asc, created_at: :asc) }

  STATUS_TYPES = {
    started: 'started',
    running: 'running',
    completed: 'completed',
    closed: 'closed'
  }.freeze
  enum status: STATUS_TYPES

  after_update :check_status_change

  def last_frame_pins
    rolls[18].pins_knocked_down + rolls[19].pins_knocked_down
  end

  def calculate_score
    # total_score = 0
    frame = 1
    roll_index = 0
    frame_score = []

    while frame <= 10 && roll_index < rolls.length
      roll1 = rolls[roll_index]
      roll2 = rolls[roll_index + 1]
      roll3 = rolls[roll_index + 2]

      frame_score << { "frame_#{frame}" => frame_score(roll1, roll2, roll3) }
      # total_score += frame_score[frame - 1]["frame_#{frame}"]
      roll_index += next_roll_index(roll1)
      frame += 1
    end

    frame_score
  end

  def next_roll_index(roll)
    roll.pins_knocked_down == 10 ? 1 : 2
  end

  def frame_score(roll1, roll2, roll3)
    if strike?(roll1)
      10 + strike_bonus(roll2, roll3)
    elsif spare?(roll1, roll2)
      10 + spare_bonus(roll3)
    else
      roll1.pins_knocked_down + (roll2&.pins_knocked_down || 0)
    end
  end

  private

  def strike?(roll)
    roll.pins_knocked_down == 10
  end

  def spare?(roll1, roll2)
    roll1.pins_knocked_down + (roll2&.pins_knocked_down || 0) == 10
  end

  def strike_bonus(roll2, roll3)
    (roll2&.pins_knocked_down || 0) + (roll3&.pins_knocked_down || 0)
  end

  def spare_bonus(roll3)
    roll3&.pins_knocked_down || 0
  end

  def check_status_change
    return unless saved_change_to_attribute?(:status) && status == STATUS_TYPES[:closed]

    ActionCable.server.broadcast("game_channel_#{id}", { status: status })
  end
end
