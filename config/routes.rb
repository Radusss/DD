Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  get 'users/home', to: 'users#home', as:'user_home'
  post '/deliveries', to: 'deliveries#create'
  root "pages#login"
end
