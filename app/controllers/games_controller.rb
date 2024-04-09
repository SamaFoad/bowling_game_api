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
    game = Game.find(params[:id])
    render json: { status: game.status }
  end

  def score
    game = Game.find(params[:id])
    frame_score = game.calculate_score
    render json: {
      total_score: game.total_score,
      frames_score: frame_score
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
