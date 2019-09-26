Rails.application.routes.draw do
  # No Devise modules are enabled
  # Custom Warden strategy is used instead see app/warden/magic_link_token.rb
  # Custom views are used, see app/views/magic_link/sign_up/
  devise_for :candidates, skip: :all

  root to: redirect('/candidate')

  namespace :candidate_interface, path: '/candidate' do
    get '/' => 'start_page#show', as: :start
    get '/welcome', to: 'welcome#show'
    get '/sign-up', to: 'sign_up#new', as: :sign_up
    post '/sign-up', to: 'sign_up#create'

    get '/sign-in', to: 'sign_in#new', as: :sign_in
    post '/sign-in', to: 'sign_in#create'
  end

  namespace :vendor_api, path: 'api/v1' do
    get '/ping', to: 'ping#ping'
  end

  namespace :provider, path: '/provider' do
    get '/' => 'home#index'
  end
end
