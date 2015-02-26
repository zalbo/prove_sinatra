require 'sinatra'
require 'pry'

class Form
  attr_reader :messages
  def initialize
    @messages = []
    @id = 0
  end

  def a_valid_email?(email)
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
    (email =~ email_regex) == 0
  end

  def id
    @id += 1
  end

  def validate_form(params)
    errors = {}

    errors[:email] = 'email is empty' if params[:email] == ''

    if errors.empty? && !a_valid_email?(params[:email])
      errors[:email] = 'email is not valid'
    end

    errors[:message] = 'message is empty' if params[:message].strip == ''

    errors
  end
end

f = Form.new

get '/' do
  @messages = f.messages
  @errors = {}
  erb :index
end

post '/' do
  @messages = f.messages
  @errors = f.validate_form(params)

  if @errors.empty?
    @messages << { email: params[:email], message: params[:message].strip, id: f.id }
  end

  erb :index
end

get '/delete/:id' do
  f.messages.delete_if { |m| m[:id] == params[:id].to_i }
  redirect('/')
end

get '/edit/:id' do
  @message =  f.messages.find { |m| m[:id] == params[:id].to_i }
  @errors = {}
  erb :edit
end

post '/edit/:id' do
  @message =  f.messages.find { |m| m[:id] == params[:id].to_i }
  @errors = f.validate_form(params)

  if @errors.empty?
    @message[:message] = params[:message]
    @message[:email] = params[:email]
    redirect('/')
  end

  erb :edit
end
