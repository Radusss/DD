Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' }
  get 'users/home', to: 'users#home', as:'user_home'
  post '/deliveries', to: 'deliveries#create'
  patch '/deliveries/update_status', to: 'deliveries#update_status'
  patch '/driver_home/load_car', to: 'deliveries#load_car', as: :load_car
  patch '/driver_home/start_delivery', to: 'deliveries#start_delivery', as: :start_delivery
  patch '/deliveries/:id/done', to: 'deliveries#done', as: 'delivery_done'
  root "pages#login"
  get '/deliveries', to: 'deliveries#index'
  post 'charge', to: 'users#charge'
end
