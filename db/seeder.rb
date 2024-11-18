require 'sqlite3'
require 'bcrypt'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todo')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute('CREATE TABLE todo (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                description TEXT,
                done BOOLEAN DEFAULT FALSE)');

    db.execute('CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT,
                password TEXT)');
  end

  

  def self.populate_tables 
    db.execute('INSERT INTO todo (name, description) VALUES ("Buy groceries", "Milk, eggs, butter")')
    db.execute('INSERT INTO todo (name, description) VALUES ("Mow the lawn", "Backyard")')  
    db.execute('INSERT INTO todo (name, description) VALUES ("Go to the gym", "Leg day")')

    password_hashed = BCrypt::Password.create("admin")
    db.execute('INSERT INTO users (username, password) VALUES ("admin", ?)', [password_hashed])
  end

  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!