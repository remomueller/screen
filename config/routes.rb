Screen::Application.routes.draw do

  resources :visits

  resources :evaluations

  resources :choices

  resources :clinics

  resources :doctors

  resources :calls do
    member do
      post :show_group
    end
    collection do
      post :task_tracker_templates
    end
  end

  resources :mailings do
    collection do
      get :bulk
      post :import
    end
  end

  resources :events

  resources :patients do
    member do
      post :inline_update
      post :stickies
    end
  end

  resources :prescreens do
    member do
      post :inline_update
    end
    collection do
      get :bulk
      post :import
    end
  end

  devise_for :users, controllers: { registrations: 'contour/registrations', sessions: 'contour/sessions', passwords: 'contour/passwords' }, path_names: { sign_up: 'register', sign_in: 'login' }

  resources :users

  match "/about" => "sites#about", as: :about

  root to: 'sites#dashboard'

end
