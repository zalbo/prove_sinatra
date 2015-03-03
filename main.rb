require 'sinatra'
require 'active_record'
require 'sqlite3'
require 'logger'
require 'shotgun'
require 'pry'


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

get '/' do
  @messages = Message.all()
  erb :index
end

post '/' do
  @messages = Message.all()
  Message.create({ :message => params[:message].strip , :email => params[:email]})
  @errors_message = Message.create.errors[:message]
  @errors_email = Message.create.errors[:email]
  erb :index
end

get '/delete/:id' do
  Message.find(params[:id].to_i).destroy
  redirect('/')
end

get '/edit/:id' do
  @message = Message.find(params[:id].to_i)
  erb :edit
end

post '/edit/:id' do
  @messages = Message.all()
  @message = Message.find(params[:id].to_i)
  Message.update(params[:id].to_i, :message => params[:message].strip , :email => params[:email])
  @errors = Message.create.errors.full_messages
  erb :index
end
