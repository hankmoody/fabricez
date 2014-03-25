Fabricez::Application.routes.draw do
  # devise_for :users, :controllers => {:sessions => 'sessions', :registrations => 'registrations'}
  devise_for :users
  
  resources :fabrics do
    member do
      get 'crop'
      put 'update_crop'
    end
    collection do
      get 'bulk_edit'
      put 'update_multiple'
      get 'portfolio'
      get 'upload'
    end
  end
  
  resources :collections do
    member do
      put 'filter'
      get 'ezalbum'
    end
    collection do
      get 'manage'
      get 'refresh'
    end
  end
  resources :users do
    member do
      put 'update_collection'
      get 'check_if_signed_in'
    end
  end
  root :to => 'pages#home'
  get '/home', :to => 'pages#home'
  get '/explore', :to => 'pages#explore'
#  get '/user', :to => 'users#show' # Adding show action to User
#  get '/upload', :to => 'fabrics#upload'
  get '/get-upload-info', :to => 'users#upload'
 
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
