Wikiapp::Application.routes.draw do
  root 'welcome#index'
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
end
