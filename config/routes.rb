ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  map.connect '', :controller => "home"

  # Public profiles
  map.connect '/members/profile/:nickname',
              :controller => 'members',
              :action => 'public_profile'

  # Tags
  map.connect 'tag/:tag',
              :controller => 'memory',
              :action => 'tag_list'

  # Listings
  map.connect ':year/:month/:day',
              :controller => 'memory',
              :action => 'list',
              :year => /\d{4}/, :month => /\d+/, :day => /\d+/
              
  map.connect ':year/:month',
              :controller => 'memory',
              :action => 'list',
              :year => /\d{4}/, :month => /\d+/
              
  map.connect ':year',
              :controller => 'memory',
              :action => 'list',
              :year => /\d{4}/
              
  # Posts
  map.connect ':year/:month/:day/:url_name',
              :controller => 'memory',
              :action => 'details',
              :year => /\d{4}/, :month => /\d+/, :day => /\d+/
              
  map.connect ':year/:month/:url_name',
              :controller => 'memory',
              :action => 'details',
              :year => /\d{4}/, :month => /\d+/
              
  map.connect ':year/:url_name',
              :controller => 'memory',
              :action => 'details',
              :year => /\d{4}/

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
