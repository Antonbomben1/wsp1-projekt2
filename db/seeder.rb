require 'sqlite3'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todo')
  end
  def self.create_tables
    db.execute('CREATE TABLE todo (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                description TEXT)')
  end

  def self.populate_tables 
    db.execute('INSERT INTO todo (description) VALUES ("Buy groceries")')
    db.execute('INSERT INTO todo (description) VALUES ("Mow the lawn")')
    db.execute('INSERT INTO todo (description) VALUES ("Go to the gym")')
    db.execute('INSERT INTO todo (description) VALUES ("Go to the gym2")')
    #db.execute('INSERT INTO fruits (name, tastiness, description, color) VALUES ("Banan",  4, "En avlång frukt." , "Gul 🟡")')

  end

  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!