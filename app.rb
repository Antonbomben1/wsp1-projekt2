class App < Sinatra::Base
    def db
        return @db if @db

        @db = SQLite3::Database.new("db/todo.sqlite")
        @db.results_as_hash = true

        return @db
    end

    get '/' do
        @todo = db.execute("SELECT * FROM todo")
        erb :index
      end
    
    post '/todo' do
        name = params[:name]
        description = params[:description]
        db.execute("INSERT INTO todo (name, description) VALUES (?,?)", [name, description])
        redirect '/'
      end
    
    post '/todo/:id/delete' do
        db.execute("DELETE FROM todo WHERE id = ?", [params[:id]])
        redirect '/'
      end


    post '/todo/:id/:done' do |id, done|
        if done == "1"
            db.execute("UPDATE todo SET done = 0 WHERE id = ?", [params[:id]])
        elsif done == "0"
            db.execute("UPDATE todo SET done = 1 WHERE id = ?", [params[:id]])
        end
        redirect '/'
      end
end
