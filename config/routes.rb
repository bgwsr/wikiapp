require 'api_constraints'
Wikiapp::Application.routes.draw do
  root 'wsw#index'
  
  get '/moderator', to: "moderator#index"
  get '/verify-entry', to: "moderator#verify_entry", as: "page_verify"
  get '/edit-entry/(:silk_identifier)/(:key)', to: "wsw#edit", as: "page_edit"
  get '/information/(:country)/(:page)', to: "wsw#information", as: "information_edit"
  
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  
  namespace :api, defaults: {format: :json} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true) do
      resources :submissions, except: :show
      post "submissions/merge", to: "submissions#merge"
      get "submissions/accept", to: "submissions#accept"
      get "submissions/silker/:silk_identifier", to: "submissions#silker"
      get "submissions/get_silk/:silk_identifier", to: "submissions#silker_page"
      post "submissions/update_silk", to: "submissions#update_silk", as: "information_update"
      post "submissions/queue", to: "submissions#queue_updates", as: "queue_updates"
      
    end
  end
end
