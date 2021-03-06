Rails.application.routes.draw do
  get '/select/:user/:repo'           , to: 'options#select'
  get '/index/:user'                  , to: 'root#index'
  get '/export/:user/:repo.:format'   , to: 'issues#export'
  get '/auth/:provider/callback'      , to: 'sessions#create'
  get '/logout'                       , to: 'sessions#destroy'
  get '/support_pages/about'          , to: 'support_pages#about'
  get '/support_pages/privacy'        , to: 'support_pages#privacy'
  get '/support_pages/terms'          , to: 'support_pages#terms'
  get '/support_pages/contact'        , to: 'support_pages#contact'
  get '/support_pages/approval'       , to: 'support_pages#approval'
  root 'root#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
