# For details on the DSL available within this file,
# see https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
    resources :collections do
        member do
            get 'export'
        end
    end
    resources :searches
    post 'collections/validate'
    # get 'collections/export'
    get 'collection_items/index'
    get 'collection_items/edit'
    post 'collection_items/addvideos'
    post 'collection_items/addchannel'
    root to: "welcome#index"
    get 'welcome/index'
    devise_for :users
    # resources :collections
    resources :videos
    resources :helms
    resources :channels
    resources :exports
    get 'search/channels'
end
