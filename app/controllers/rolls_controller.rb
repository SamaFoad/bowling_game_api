class RollsController < ApplicationController
  def create
    game = Game.find(params[:game_id])
    roll = game.rolls.new(pins_knocked_down: params[:pins_knocked_down])

    if roll.save
      render json: { status: 'Roll recorded' }
    else
      render json: { errors: roll.errors.full_messages, status: 'Roll failed' }, status: 422
    end
  end
end
