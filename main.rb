
require 'sinatra'
require 'pry'
#  binding.pry






before do
  @messages = []
end

get "/" do
  @messages << params[:message]
 erb :index
end



post "/" do

  @messages << params[:message]

  erb :index
end
