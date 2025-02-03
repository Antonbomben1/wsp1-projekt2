class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todos')
    db.execute('DROP TABLE IF EXISTS users')
    db.execute('DROP TABLE IF EXISTS folders') # Drop folders table
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
    # Insert unique folder names
    folders = %w[Work Personal Trip]
    folders.each do |folder_name|
      db.execute('INSERT OR IGNORE INTO folders (name) VALUES (?)', [folder_name])
    end

    # Insert sample users
    password_hashed = BCrypt::Password.create("admin")
    db.execute('INSERT INTO users (username, password) VALUES ("admin", ?)', [password_hashed])
    db.execute('INSERT INTO users (username, password) VALUES ("u1", ?)', [password_hashed])
    db.execute('INSERT INTO users (username, password) VALUES ("u2", ?)', [password_hashed])

    # Insert sample todos
    db.execute('INSERT INTO todos (name, user_id, description, folder_id) VALUES ("Buy groceries", 1, "Milk, eggs, butter", 4)')
    db.execute('INSERT INTO todos (name, user_id, description, folder_id) VALUES ("Plan itinerary", 1, "Details for the trip", 4)')
  
    #lägg in 3 test-folders
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Test Folder 1", 1)')
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Test Folder 2", 1)')
    db.execute('INSERT INTO folders (name, user_id) VALUES ("Test Folder 3", 2)')
  end

  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end
