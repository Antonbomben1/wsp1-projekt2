
require 'sinatra'
require 'securerandom'
require 'sqlite3'
require 'json'
require './db/seeder'
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

      if user && BCrypt::Password.new(user["password"]) == password and user["username"] == "admin" 
        redirect '/admin'
      elsif user && BCrypt::Password.new(user["password"]) == password
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

    @folders = db.execute("SELECT * FROM folders WHERE user_id = ?", [session[:user]["id"]])
  
    # För varje folder, hämta antalet 'done' och 'not_done' todos
    @folders.each do |folder|
      folder['todo_count'] = {
        done: db.execute("SELECT COUNT(*) FROM todos WHERE folder_id = ? AND done = 1", [folder['id']]).first['COUNT(*)'],
        not_done: db.execute("SELECT COUNT(*) FROM todos WHERE folder_id = ? AND done = 0", [folder['id']]).first['COUNT(*)']
      }
    end
  
    erb :index
  end

  get '/admin' do
    # Hämta alla användare
    @users = db.execute("SELECT * FROM users")
  
    # Hämta alla mappar (folders)
    @folders = db.execute("SELECT * FROM folders")
  
    # För varje mapp, räkna hur många todos som är klara och ej
    @folders.each do |folder|
      folder['todo_count'] = {
        done: db.execute("SELECT COUNT(*) FROM todos WHERE folder_id = ? AND done = 1", [folder['id']]).first['COUNT(*)'],
        not_done: db.execute("SELECT COUNT(*) FROM todos WHERE folder_id = ? AND done = 0", [folder['id']]).first['COUNT(*)']
      }
    end
  
    # Hämta alla todos och deras tillhörande användare
    @todos = db.execute("SELECT todos.*, users.username FROM todos JOIN users ON todos.user_id = users.id")
  
    erb :admin_user_todo
  end
  
  
      
    
      post '/todo' do
        name = params[:name]
        description = params[:description]
        db.execute("INSERT INTO todos (name, user_id, description, folder_id) VALUES (?, ?, ?, ?)", [name, session[:user]["id"], description, params[:folder_id]])
        redirect '/'
      end    

      post '/folders/create' do
          name = params[:name]
          db.execute("INSERT INTO folders (name, user_id) VALUES (?, ?)", [name, session[:user]["id"]])
          redirect '/'
        end
      
    
    post '/todo/:id/delete' do
      
        folder_id = db.execute("SELECT folder_id FROM todos WHERE id = ?", [params[:id]])[0]["folder_id"]

        db.execute("DELETE FROM todos WHERE id = ?", [params[:id]])
        redirect '/folders/' + folder_id.to_s
      end


    post '/todo/:id/:done' do |id, done|
        if done == "1"
            db.execute("UPDATE todos SET done = 0 WHERE id = ?", [params[:id]])
        elsif done == "0"
            db.execute("UPDATE todos SET done = 1 WHERE id = ?", [params[:id]])
        end
        folder_id = db.execute("SELECT folder_id FROM todos WHERE id = ?", [params[:id]])[0]["folder_id"]
        redirect '/folders/' + folder_id.to_s
      end
      
        # Route to display all folders
    get '/folders' do
    @folders = db.execute("SELECT * FROM folders")
    erb :folders_list  # Display the folders list
    end

    # Route to display the form to create a folder
    get '/folders/new' do
    erb :new_folder  # Form to create a new folder
    end

    # Route to create a folder
    post '/folders' do
    folder_name = params[:folder_name]
    db.execute("INSERT INTO folders (name) VALUES (?)", [folder_name])
    redirect '/folders'  # Redirect back to the list of folders
    end

    get '/' do
        @folders = db.execute("SELECT * FROM folders")
        @todos = db.execute("SELECT * FROM todos WHERE user_id = ?", [session[:user]["id"]])
        erb :index
     end

    post '/todo' do
        name = params[:name]
        description = params[:description]
        folder_id = params[:folder_id]
      
        db.execute("INSERT INTO todos (name, user_id, description, folder_id) VALUES (?, ?, ?, ?)", 
                   [name, session[:user]["id"], description, folder_id])
        redirect '/'
      end
            
      post '/create_folder' do
        folder_name = params[:folder_name]
        db.execute('INSERT INTO folders (name, folder_id) VALUES (?)', [folder_name])
        redirect '/'  # Redirect back to the homepage after creating the folder
      end
      
      
      get '/folders/new' do
        erb :new_folder
      end

      get '/folders/:id' do
        folder_id = params[:id]
        @folder = db.execute("SELECT * FROM folders WHERE id = ?", [folder_id]).first
        @todos = db.execute("SELECT * FROM todos WHERE folder_id = ?", [folder_id])
    
        erb :show 
      end

      
    
      
     

    
end
