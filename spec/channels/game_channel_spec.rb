require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  let(:game) { create(:game) }

  before do
    allow_any_instance_of(GameChannel).to receive(:stream_for).and_return(nil)
    subscribe(game_id: game.id)
  end

  it 'successfully subscribes to the channel' do
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_from("game_channel_#{game.id}")
  end

  it 'can successfully broadcast' do
    expect { broadcast_score }.to have_broadcasted_to("game_channel_#{game.id}")
  end

  it 'successfully broadcasts the game score and status' do
    expect { game.rolls.create(pins_knocked_down: 2) }.to have_broadcasted_to("game_channel_#{game.id}")
  end

  it 'successfully broadcasts on changing status to closed' do
    expect { game.update(status: 'closed') }.to have_broadcasted_to("game_channel_#{game.id}")
  end

  def broadcast_score
    ActionCable.server.broadcast("game_channel_#{game.id}", { score: game.calculate_score, status: game.status })
  end
end
