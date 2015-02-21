
require 'sinatra'
require 'pry'


class Form

   attr_reader :messages
   def initialize
     @messages = []
   end
end

def is_a_valid_email?(email)
    email_regex = %r{
      ^ # Start of string
      [0-9a-z] # First character
      [0-9a-z.+]+ # Middle characters
      [0-9a-z] # Last character
      @ # Separating @ character
      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end
      $ # End of string
    }xi # Case insensitive

    (email =~ email_regex)
end

f = Form.new

get "/" do
  @messages = f.messages
  erb :index
end

post "/" do
  @messages = f.messages
  if is_a_valid_email?(params[:email]) == 0
    @messages << {email:params[:email] , message:params[:message]}
  else
    @error_message = "errore email non valida, riscrivere"
  end
erb :index
end
