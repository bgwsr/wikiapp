require 'api_constraints'
Wikiapp::Application.routes.draw do
  root 'wsw#index'
  
  get '/moderator', to: "moderator#index"
  get '/verify-entry', to: "moderator#verify_entry"
  get '/edit-entry/(:silk_identifier)', to: "wsw#edit", as: "page_edit"
  
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  
  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :submissions, except: :show
      post "submissions/merge", to: "submissions#merge"
      get "submissions/accept", to: "submissions#accept"
    end
  end
end
