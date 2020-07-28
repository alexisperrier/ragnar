# For details on the DSL available within this file,
# see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  resources :videos
    devise_for :users
    root to: "channels#index"
    resources :helms
    resources :channels
    resources :exports
    get 'search/channels'
end
