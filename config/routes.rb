Screen::Application.routes.draw do

  resources :calls

  resources :choices

  resources :clinics

  resources :doctors

  resources :evaluations

  resources :events

  resources :mailings do
    collection do
      get :bulk
      post :import
    end
  end



  resources :patients

  resources :prescreens do
    collection do
      get :bulk
      post :import
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords', confirmations: 'contour/confirmations', unlocks: 'contour/unlocks' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  resources :visits

  get "/about" => "application#about", as: :about
  get "/about/use" => "application#use", as: :about_use

  root to: 'application#dashboard'

end
