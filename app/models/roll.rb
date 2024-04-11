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

  after_create :update_game_status, :update_total_score
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
    if game.completed_frames > 10
      game.completed!
    elsif game.started?
      game.running!
    end
  end

  def update_total_score
    total_score = game.calculate_score.sum(&:values).sum
    game.update!(total_score: total_score)
  end

  def broadcast_game_score
    update_redis_scores_and_status
    broadcast_score_update
  end

  def update_redis_scores_and_status
    $redis.set("game:#{game.id}:frames_score", game.calculate_score.to_json)
    $redis.set("game:#{game.id}:total_score", game.total_score)
    $redis.set("game:#{game.id}:status", game.status)
  end

  def broadcast_score_update
    frames_score = JSON.parse($redis.get("game:#{game.id}:frames_score"))
    total_score = $redis.get("game:#{game.id}:total_score").to_i
    game_status = $redis.get("game:#{game.id}:status")
    ActionCable.server.broadcast("game_channel_#{game.id}",
                                 { total_score: total_score,
                                   frames_score: frames_score,
                                   status: game_status })
  end
end
