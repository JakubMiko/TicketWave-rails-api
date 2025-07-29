Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  devise_for :admins, controllers: {
    registrations: "admins/registrations",
    sessions: "admins/sessions"
  }, path: "admins", class_name: "User"

  namespace :users do
    get "dashboard", to: "dashboard#show", as: :dashboard
    resource :token, only: [ :show ]
  end

  namespace :admins do
    get "dashboard", to: "dashboard#show", as: :dashboard
  end

  resources :events do
    resources :ticket_batches
  end

  resources :orders, only: [ :index, :show, :create ] do
    get "confirmation", on: :member
  end

  get "events/:event_id/ticket_batches/:ticket_batch_id/orders/new", to: "orders#new", as: "new_ticket_batch_order"

  root to: "landing#show"
  get "up" => "rails/health#show", as: :rails_health_check
end
