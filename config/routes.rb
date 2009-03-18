ActionController::Routing::Routes.draw do |map|
  map.rorir              'rorir/:style/:text.:format', :controller => 'rorir', :action => 'show_with_style'
  map.rorir_with_options 'rorir/:text.:format',        :controller => 'rorir', :action => 'show_without_style'
end