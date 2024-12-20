
require 'sinatra'
require 'securerandom'
class App < Sinatra::Base
 
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    configure do  
        enable :sessions
        set :session_secret, SecureRandom.hex(64)
    end

    get '/login' do
        if !session[:user]
            erb :login
        else
            redirect '/'
            end
    end

    post '/login' do
      username = params[:username]
      password = params[:password]

      user = db.execute("SELECT * FROM users WHERE username = ?", [username]).first

      if user && BCrypt::Password.new(user["password"]) == password
          session[:user] = user
          redirect '/'
      else
          @error = "Invalid username or password"
          erb :login
      end
  end

  post '/logout' do
      session.clear
      redirect '/login'
  end

  before do
      protected_routes = ['/', '/todo', '/todo/:id/delete', '/todo/:id/:done']
      if protected_routes.include?(request.path_info) && session[:user].nil?
        p session[:user]  
        redirect '/login'
      end
  end

    get '/' do
        @todos = db.execute("SELECT * FROM todos WHERE user_id = ?", [session[:user]["id"]])
        erb :index
      end
    
    post '/todo' do
        name = params[:name]
        description = params[:description]
        db.execute("INSERT INTO todos (name, user_id, description) VALUES (?, ?, ?)", [name, session[:user]["id"], description])
        redirect '/'
      end
      
    
    post '/todo/:id/delete' do
        db.execute("DELETE FROM todos WHERE id = ?", [params[:id]])
        redirect '/'
      end


    post '/todo/:id/:done' do |id, done|
        if done == "1"
            db.execute("UPDATE todos SET done = 0 WHERE id = ?", [params[:id]])
        elsif done == "0"
            db.execute("UPDATE todos SET done = 1 WHERE id = ?", [params[:id]])
        end
        redirect '/'
      end
    
end
