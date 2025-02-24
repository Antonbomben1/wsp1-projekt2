
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
      p session[:user]["id"]

      @folders = db.execute("SELECT * FROM folders")
      p "Anton är lite homosexuell!!!"
      p @folders
      @todos = db.execute("SELECT * 
      FROM todos 
        INNER JOIN users ON todos.user_id = users.id
        INNER JOIN folders ON todos.folder_id = folders.id")
      erb :index
      end
    
      post '/todo' do
        name = params[:name]
        description = params[:description]
        db.execute("INSERT INTO todos (name, user_id, description, folder_id) VALUES (?, ?, ?, ?)", [name, session[:user]["id"], description, params[:folder_id]])
        redirect '/'
      end    

      post '/folders/create' do
          name = params[:name]
          db.execute("INSERT INTO folders (name, user_id) VALUES (?, ?)", [name, 1])
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

    # Route to display tasks for a specific folder
    get '/folders/:id' do
    folder_id = params[:id].to_i
    @folder = db.execute("SELECT * FROM folders WHERE id = ?", [folder_id]).first
    @tasks = db.execute("SELECT * FROM todos WHERE folder_id = ?", [folder_id])
    erb :folder_tasks  # Show the tasks within this folder
    end
    get '/' do
        @folders = db.execute("SELECT * FROM folders")
        p "Anton är lite homosexuell!!!"
        p @folders
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
      
     

    
end
