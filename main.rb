
require 'sinatra'
require 'pry'


class Form

   attr_reader :array_form
   def initialize
     @array_form = []
   end
end

f = Form.new

get "/" do
  @messages = f.array_form
  erb :index
end

post "/" do
  @messages = f.array_form
  f.array_form << params[:message]
  erb :index
end
