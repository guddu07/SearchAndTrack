Rails.application.routes.draw do
  get 'activities/index'
  resources :activities
  resources :products do
    collection do
      get 'get_tags'
    end
  end

  devise_for :users
  root to: "products#index"
end
