# encoding: UTF-8

=begin

Procède à des opérations sur la table Users, sans passer par la
classe BdD, à commencer par la lecture des données.

=end
require 'sqlite3'

db = SQLite3::Database::new("./database/data/users.db")
table_name = "users"

request = "SELECT * FROM users"

res = db.execute request

res.each do |arr_user|
  puts arr_user.inspect
end
