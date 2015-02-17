require 'rubygems'
require 'sinatra'


get "/" do
  erb :index
end

post '/form' do
  "You said '#{params[:message]}'"

  erb :index

end
