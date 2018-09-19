Rails.application.routes.draw do
  #confirmの追加
  get '/confirm/:id', to:'posts#confirm', as: :confirm
  resources :posts, only: [:create, :show, :edit, :update]
  root to: "posts#new"

end
