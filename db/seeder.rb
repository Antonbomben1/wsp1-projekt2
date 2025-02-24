class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todos')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS folders')
  end

  def self.create_tables
    db.execute('CREATE TABLE folders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      name TEXT UNIQUE NOT NULL
    )')

    db.execute('CREATE TABLE todos (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      user_id INTEGER NOT NULL,
      description TEXT,
      due_date DATE,
      folder_id INTEGER,
      done BOOLEAN DEFAULT FALSE,
      FOREIGN KEY (user_id) REFERENCES users(id),
      FOREIGN KEY (folder_id) REFERENCES folders(id)
    )')

    db.execute('CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password TEXT
    )')
  end

  def self.populate_tables
    password_hashed = BCrypt::Password.create("admin")
    db.execute('INSERT INTO users (username, password) VALUES ("admin", ?)', [password_hashed])
    db.execute('INSERT INTO users (username, password) VALUES ("u1", ?)', [password_hashed])
    db.execute('INSERT INTO users (username, password) VALUES ("u2", ?)', [password_hashed])

    # Skapa mappar kopplade till användare
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Work", 1)')
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Personal", 2)')
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Trip", 3)')

    # Skapa uppgifter kopplade till användare och mappar
    db.execute('INSERT INTO todos (name, user_id, description, folder_id) VALUES ("Buy groceries", 1, "Milk, eggs, butter", 1)')
    db.execute('INSERT INTO todos (name, user_id, description, folder_id) VALUES ("Plan itinerary", 2, "Details for the trip", 2)')
  end

  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end

# Testa INNER JOIN
Seeder.seed!