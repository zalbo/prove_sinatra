require 'sinatra'
require 'pry'


class Form
  attr_reader :messages
  def initialize
    @messages = []
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
    return (email =~ email_regex) == 0
  end

  def validate_form(params)
    errors = {}
    if params[:email] == ""
      errors[:email] = "email is empty"
    end

    if errors.empty? && !is_a_valid_email?(params[:email])
      errors[:email] = "email is not valid"
    end

    if params[:message].strip == ""
      errors[:message] = "message is empty"
    end

    errors
  end
end


f = Form.new
@@id = 0

def upgrate_id
 @@id = @@id +  1
end

get "/" do
  @messages = f.messages
  @errors = {}
  erb :index
end

post "/" do
  @messages = f.messages
  @errors = f.validate_form(params)
  if @errors.empty?
    @messages << {email:params[:email] , message:params[:message].strip , id:@@id}

  end
  upgrate_id
  erb :index
end

get "/delete/:id" do
  binding.pry
 f.messages.delete_at(params[:id].to_i)
 redirect('/')
end
