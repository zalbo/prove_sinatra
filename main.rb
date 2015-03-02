require 'sinatra'
require 'active_record'
require 'sqlite3'
require 'logger'


ActiveRecord::Base.logger = Logger.new(STDOUT) 

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'zalbo.db'
)

class CreateMessageMigration < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :email
      t.text :message
    end
  end 
end

ActiveRecord::Migrator.migrate CreateMessageMigration

begin 
  CreateMessageMigration.new.migrate(:up)
rescue ActiveRecord::StatementInvalid
  puts "table messages already exists" 
end


class Message < ActiveRecord::Base
  validates_presence_of :message
  validates :email, format: { with: /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/ }
end



Message.all.each do |message|
  puts message.email
  puts message.message
end






db = SQLite3::Database.open 'zalbo.db'
db.execute 'CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY, message TEXT, email TEXT)'

class Form
  attr_reader :messages

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
  stm = db.prepare 'SELECT * FROM messages ORDER BY id desc'
  rs = stm.execute
  @messages = []
  rs.each do |row|
    @messages << { id: row[0], message: row[1], email: row[2] }
  end

  @errors = {}
  erb :index
end

post '/' do
  @errors = f.validate_form(params)

  if @errors.empty?
    db.execute "INSERT INTO messages(email, message) VALUES ('#{params[:email]}', '#{params[:message].strip}')"
  end

  stm = db.prepare 'SELECT * FROM messages ORDER BY id desc'
  rs = stm.execute
  @messages = []
  rs.each do |row|
    @messages << { id: row[0], message: row[1], email: row[2] }
  end

  erb :index
end

get '/delete/:id' do
  db.execute "DELETE FROM  messages WHERE id = #{params[:id]}"
  redirect('/')
end

get '/edit/:id' do
  stm = db.prepare "SELECT * FROM messages WHERE id = #{params[:id]}"
  rs = stm.execute
  rs.each do |row|
    @message = { id: row[0], message: row[1], email: row[2] }
  end
  @errors = {}
  erb :edit
end

post '/edit/:id' do
  @errors = f.validate_form(params)

  if @errors.empty?
    db.execute "UPDATE messages SET email = '#{params[:email]}', message = '#{params[:message].strip}' WHERE id = #{params[:id]}"
    redirect('/')
  end

  erb :edit
end
