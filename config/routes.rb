Screen::Application.routes.draw do

  resources :events

  resources :patients

  resources :prescreens do
    collection do
      post :bulk
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords' }, path_names: { sign_up: 'register', sign_in: 'login' }

  root to: 'prescreens#index'

end
