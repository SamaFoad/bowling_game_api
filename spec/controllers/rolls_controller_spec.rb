require 'rails_helper'

RSpec.describe RollsController, type: :controller do
  describe 'POST create' do
    let(:game) { Game.create }

    it 'creates a new roll for the game' do
      post :create, params: { game_id: game.id, pins_knocked_down: 5 }
      expect(response).to have_http_status(:success)
      expect(game.rolls.count).to eq(1)
    end

    it 'fails to create new roll pins_knocked_down is not an integer' do
      post :create, params: { game_id: game.id, pins_knocked_down: 'two' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['status']).to eq('Roll failed')
    end

    it 'fails to create new roll pins_knocked_down is less than 10' do
      post :create, params: { game_id: game.id, pins_knocked_down: -2 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['status']).to eq('Roll failed')
    end

    it 'fails to create new roll pins_knocked_down is more than 10' do
      post :create, params: { game_id: game.id, pins_knocked_down: 11 }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['status']).to eq('Roll failed')
    end
  end
end
