# For details on the DSL available within this file,
# see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
    root to: "welcome#index"
    get 'welcome/index'
    devise_for :users
    resources :collections
    resources :videos
    resources :helms
    resources :channels
    resources :exports
    get 'search/channels'
end
