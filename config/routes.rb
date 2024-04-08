Rails.application.routes.draw do
  Rails.application.routes.draw do
    resources :games, only: [:create, :show] do
      resources :rolls, only: :create
      member do
        get 'score'
        get 'status'
        put 'close'
      end
    end
  end
end
