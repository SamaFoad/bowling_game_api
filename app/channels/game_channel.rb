class GameChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_channel_#{params[:game_id]}"
    # We can broadcast every 2 seconds if we still need it
    # check_game_score
  end

  def unsubscribed
    stop_checking_game_score
  end

  private

  def check_game_score
    broadcast_game_score

    @checking_thread = Thread.new do
      loop do
        sleep 2.seconds
        broadcast_game_score
      end
    end
  end

  def broadcast_game_score
    game = Game.find_by(id: params[:game_id])
    return unless game.present?

    score = game.calculate_score

    GameChannel.broadcast_to("game_channel_#{params[:game_id]}",
                             { score: score, status: game.status })
  end

  def stop_checking_game_score
    @checking_thread&.kill
  end
end
