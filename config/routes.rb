Rails.application.routes.draw do
  root 'homes#index'
  post 'master_data', to: 'homes#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
