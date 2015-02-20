
require 'sinatra'
require 'pry'


class Form

   attr_reader :array_message , :array_mail
   def initialize
     @array_message = []
     @array_mail = []
   end
end

f = Form.new

get "/" do
  @messages = f.array_message
  @emails = f.array_mail
  erb :index
end

post "/" do
  @messages = f.array_message
  @emails = f.array_mail
  f.array_message << params[:message]
  f.array_mail << params[:email]


  erb :index
end
