Rails.application.routes.draw do
  get 'games/highest_score', to: 'games#highest_score'

  resources :games, only: %i[index create show] do
    resources :rolls, only: :create
    member do
      get 'score'
      get 'status'
      put 'close'
    end
  end
end
