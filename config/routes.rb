require 'api_constraints'
Wikiapp::Application.routes.draw do
  root 'welcome#index'
  
  get '/moderator', to: "moderator#index"
  get '/verify-entry', to: "moderator#verify_entry"
  
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  
  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :submissions
      post "submissions/merge", to: "submissions#merge"
    end
  end
end
