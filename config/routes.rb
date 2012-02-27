Screen::Application.routes.draw do

  resources :calls

  resources :mailings

  resources :events

  resources :patients do
    member do
      post :inline_update
    end
  end

  resources :prescreens do
    member do
      post :inline_update
    end
    collection do
      post :bulk
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords' }, path_names: { sign_up: 'register', sign_in: 'login' }

  root to: 'prescreens#index'

end
