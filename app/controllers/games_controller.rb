class GamesController < ApplicationController
  def create
    game = Game.new
    if game.save!
      render json: game
    else
      render json: { errors: game.errors.full_messages, status: 'Game failed to be created' }, status: 422
    end
  end

  def show
    game = Game.find(params[:id])
    render json: game
  end

  def index
    render json: Game.all.order(created_at: :asc)
  end

  def status
    game_status = $redis.get("game:#{params[:id]}:status")
    if game_status.blank?
      game_status = Game.where(id: params[:id]).pluck(:status).first
      $redis.set("game:#{params[:id]}:status", game_status)
    end
    render json: { status: game_status }
  end

  def score
    total_score = $redis.get("game:#{params[:id]}:total_score").to_i
    frames_score = JSON.parse($redis.get("game:#{params[:id]}:frames_score"))
    if total_score.blank? || frames_score.blank?
      game = Game.find(params[:id])
      total_score = game.total_score
      frames_score = game.calculate_score
      $redis.set("game:#{params[:id]}:total_score", total_score)
      $redis.set("game:#{params[:id]}:frames_score", frames_score)
    end

    render json: {
      total_score: total_score,
      frames_score: frames_score
    }
  end

  def highest_score
    render json: { highest_score_games: Game.highest_total_score }
  end

  def close
    game = Game.find_by(id: params[:id])

    if game
      game.update(status: 'closed')
      render json: { message: 'Game closed successfully', status: game.status }
    else
      render json: { error: 'Game not found' }, status: :not_found
    end
  end
end
