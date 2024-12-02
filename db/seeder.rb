require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todos')
    db.execute('DROP TABLE IF EXISTS users')

  end

  def self.create_tables
   
    db.execute('CREATE TABLE todos (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                user_id INTEGER NOT NULL,
                description TEXT,
                done BOOLEAN DEFAULT FALSE)')

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                password TEXT)')
  end

  

  def self.populate_tables 
    db.execute('INSERT INTO todos (name, user_id, description) VALUES ("Buy groceries", 3, "Milk, eggs, butter")')
    db.execute('INSERT INTO todos (name, user_id, description) VALUES ("Mow the lawn", 2, "Backyard")')  
    db.execute('INSERT INTO todos (name, user_id, description) VALUES ("Go to the gym", 2, "Leg day")')

    password_hashed = BCrypt::Password.create("admin")
    db.execute('INSERT INTO users (username, password) VALUES ("admin", ?)', [password_hashed])
  

  db.execute('INSERT INTO users (username, password) VALUES ("u1", ?)', [password_hashed])


  db.execute('INSERT INTO users (username, password) VALUES ("u2", ?)', [password_hashed])

  
end

  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!