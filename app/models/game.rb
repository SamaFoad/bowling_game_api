# == Schema Information
#
# Table name: games
#
#  id                      :integer          not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  status                  :string           default("started"), not null
#  total_score             :integer          default(0)
#
class Game < ApplicationRecord
  has_many :rolls, -> { order(id: :asc, created_at: :asc) }, dependent: :destroy

  STATUS_TYPES = {
    started: 'started',
    running: 'running',
    completed: 'completed',
    closed: 'closed'
  }.freeze
  enum status: STATUS_TYPES

  after_update_commit :track_game_status_change

  def self.highest_total_score
    where(total_score: maximum(:total_score))
  end

  def calculate_score
    frame = 1
    roll_index = 0
    frame_score = []

    while frame <= 10 && roll_index < rolls.length
      roll1 = rolls[roll_index]
      roll2 = rolls[roll_index + 1]
      roll3 = rolls[roll_index + 2]

      frame_score << { "frame_#{frame}" => frame_score(roll1, roll2, roll3) }
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

  def completed_frames
    frame_index = 1
    roll_index = 0

    while frame_index <= 10 && roll_index < rolls.length
      roll1 = rolls[roll_index]
      roll2 = rolls[roll_index + 1]
      roll3 = rolls[roll_index + 2]

      roll_index += next_roll_index(roll1)
      return frame_index if strike_spare_not_completed?(roll1, roll2, roll3)

      frame_index += 1 if strike_spare_completed?(roll1, roll2, roll3) || (roll1.present? && roll2.present?)
    end

    frame_index
  end

  private

  def strike?(roll)
    roll.pins_knocked_down == 10
  end

  def spare?(roll1, roll2)
    roll1.pins_knocked_down + (roll2&.pins_knocked_down || 0) == 10
  end

  def strike_spare_not_completed?(roll1, roll2, roll3)
    (strike?(roll1) || (roll2.present? && spare?(roll1, roll2))) && (roll2.blank? || roll3.blank?)
  end

  def strike_spare_completed?(roll1, roll2, roll3)
    strike?(roll1) || (roll2.present? && spare?(roll1, roll2)) && (roll2.present? && roll3.present?)
  end

  def strike_bonus(roll2, roll3)
    (roll2&.pins_knocked_down || 0) + (roll3&.pins_knocked_down || 0)
  end

  def spare_bonus(roll3)
    roll3&.pins_knocked_down || 0
  end

  def track_game_status_change
    return unless saved_change_to_status?

    $redis.set("game:#{id}:status", status)
    ActionCable.server.broadcast("game_channel_#{id}", { status: status })
  end
end
