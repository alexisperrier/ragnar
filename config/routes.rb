# For details on the DSL available within this file,
# see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  get 'lists/index'
  get 'lists/show'
  get 'lists/edit'
  get 'lists/update'
  get 'lists/new'
  get 'lists/destroy'
    root to: "welcome#index"
    get 'welcome/index'
    resources :videos
    resources :lists
    devise_for :users
    resources :helms
    resources :channels
    resources :exports
    get 'search/channels'
end
