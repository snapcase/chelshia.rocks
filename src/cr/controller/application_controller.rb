class ApplicationController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, 'public'

  enable :sessions, :method_override

  # register Sinatra::Auth
  # register Sinatra::Contact
  # register Sinatra::Flash

  # use AssetHandler

  not_found{ haml :not_found, layout: :main }
end
