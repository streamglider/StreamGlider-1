SgServer::Application.routes.draw do
  
  resources :default_streams
  post 'default_streams/move_up', :to => 'default_streams#move_up'
  post 'default_streams/move_down', :to => 'default_streams#move_down'
  post 'default_streams/upload', :to => 'default_streams#upload'
  
  resources :share_tos, :only => [:index, :destroy]

  resources :stream_feeds, :except => [:index, :show]
  post 'stream_feeds/move_up', :to => 'stream_feeds#move_up'
  post 'stream_feeds/move_down', :to => 'stream_feeds#move_down'

  post 'streams/share_stream', :to => 'streams#share_stream'
  resources :streams, :except => [:new, :edit]

  devise_for :users, :controllers => { :sessions => "users/sessions", :registrations => "users/registrations", :passwords => "users/passwords" }
  
  devise_scope :user do
    post 'auth_token', :to => 'users/sessions#auth_token', :as => :auth_token # Rails 3
    post 'change_password', :to => 'users/registrations#change_password'
    get 'users', :to => 'users/registrations#index'
    get 'password_reset_confirmed', :to => 'users/passwords#password_reset_confirmed'
  end  

  devise_for :admins, :controllers => { :registrations => "admins/registrations", :passwords => "admins/passwords" }

  devise_scope :admin do
    get 'admins', :to => 'admins/registrations#index'
  end  

  post 'featured_feeds/move_up', :to => 'featured_feeds#move_up'
  post 'featured_feeds/move_down', :to => 'featured_feeds#move_down'
  resources :featured_feeds  

  post 'feeds/move_up', :to => 'feeds#move_up'
  post 'feeds/move_down', :to => 'feeds#move_down'
  post 'feeds/clear_image', :to => 'feeds#clear_image'
  post 'feeds/sort', :to => 'feeds#sort'  
  resources :feeds

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
  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
