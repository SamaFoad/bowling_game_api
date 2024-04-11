require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:game) { create(:game) }

  describe 'POST create' do
    it 'creates a new game' do
      expect { post :create }.to change(Game, :count).by(1)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET show' do
    it 'returns the game' do
      get :show, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['id']).to eq(game.id)
    end
  end

  describe 'GET index' do
    it 'returns all games' do
      Game.create
      get :index
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body).length).to eq(Game.all.length)
    end
  end

  describe 'GET status' do
    it 'returns the game status started' do
      game = Game.create
      get :status, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['status']).to eq('started')
    end

    it 'returns the game status running' do
      game.rolls.create(pins_knocked_down: 5)

      get :status, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['status']).to eq('running')
    end
  end

  describe 'GET score' do
    it 'returns the game score' do
      game.rolls.create(pins_knocked_down: 5)
      game.rolls.create(pins_knocked_down: 2)
      game.rolls.create(pins_knocked_down: 3)
      game.rolls.create(pins_knocked_down: 7)

      get :score, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['total_score']).to eq(17)
      expect(JSON.parse(response.body)['frames_score'].length).to eq(2)
    end
  end

  describe 'GET highest score' do
    it 'returns the game score' do
      game.rolls.create(pins_knocked_down: 5)
      game.rolls.create(pins_knocked_down: 2)
      game.rolls.create(pins_knocked_down: 3)
      game.rolls.create(pins_knocked_down: 7)

      Game.create
      game.rolls.create(pins_knocked_down: 5)
      game.rolls.create(pins_knocked_down: 2)

      get :highest_score
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['highest_score_games'].length).to eq(1)
    end
  end

  describe 'PUT close' do
    it 'returns the game status started' do
      put :close, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['message']).to eq('Game closed successfully')
      expect(JSON.parse(response.body)['status']).to eq('closed')
    end

    it 'returns the game status closed' do
      put :close, params: { id: game.id }
      get :status, params: { id: game.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['status']).to eq('closed')
    end
  end
end
