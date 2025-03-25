class Folder
  def self.all_with_counts(db)
    
    folders = db.execute("SELECT * FROM folders")

   
    counts = db.execute(<<-SQL)
      SELECT folder_id,
             SUM(CASE WHEN done = 1 THEN 1 ELSE 0 END) AS done_count,
             SUM(CASE WHEN done = 0 THEN 1 ELSE 0 END) AS not_done_count
      FROM todos
      GROUP BY folder_id
    SQL

    # Skapa en hash för snabb lookup
    count_hash = {}
    counts.each do |row|
      count_hash[row["folder_id"]] = { done: row["done_count"], not_done: row["not_done_count"] }
    end

    # Lägg till counts i varje folder
    folders.each do |folder|
      folder["todo_count"] = count_hash[folder["id"]] || { done: 0, not_done: 0 }
    end

    folders
  end
end
