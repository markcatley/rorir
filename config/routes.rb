ActionController::Routing::Routes.draw do |map|
  map.rorir 'rorir/:style/:text.:format', :controller => 'rorir', :action => 'show'
end