# encoding: UTF-8
=begin

Script qui prend les informations de la table filmodico.films (qui
vient de l'atelier Icare à l'origine) et peuple la table analyse.films qui
lui correspond, avec des informations moindre, pour les analyses et aussi
la construction des liens vers les films dans les textes.

=end

raise "Normalement, il n'y a plus de raison d'utiliser ce script…"
exit 1

# require "./lib/required"
# # Dir["#{path}/**/*.rb"].each { |m| require m }
#
path_filmodico  = "./database/data/filmodico.db"
path_analyse    = "./database/data/analyse.db"
#
# db_filmodico    = BdD::new(path_filmodico)
# db_analyse      = BdD::new(path_analyse)
# table_filmodico = db_filmodico.table('films')
# table_films     = db_analyse.table('films')
#
# table_filmodico.select.values.each do |hfilm|
#   puts hfilm.inspect + "\n\n"
# end
require 'sqlite3'
require 'json'

bdd_filmodico = SQLite3::Database::new(path_filmodico)
bdd_analyse   = SQLite3::Database::new(path_analyse)
res = bdd_filmodico.execute("SELECT * FROM films")
colonnes  = ['id', 'sym', 'titre', 'titre_fr', 'annee', 'pays', 'realisateur', 'auteurs', 'options', 'created_at', 'updated_at'].join(', ')

# On détruit la table initiale
bdd_analyse.execute "DELETE FROM films"

all_requests = ""
res.each do |arr_res|
  film_id, film_id_string, titre, titre_fr, arr_pays, annee, duree, duree_generique, resume, arr_realisateur, arr_auteurs, acteurs, producteurs, musique, links = arr_res

  real = JSON.parse(JSON.parse(arr_realisateur).first)
  # puts "real: #{real.inspect}"
  realisateur = "#{real['prenom']} #{real['nom']}"

  arr_pays = JSON.parse(arr_pays)
  auteurs = JSON.parse(arr_auteurs).collect do |hauteur|
    hauteur = JSON.parse(hauteur)
    "#{hauteur['prenom']} #{hauteur['nom']}"
  end.join(', ')

  # puts "#{film_id} / #{titre} / #{sym} / #{realisateur} / #{auteurs}"

  montre = true
  sym = case titre
  when 'The Maze Runner' then 'maze_runner'
  when 'Seven' then 'seven'
  when 'Her' then 'her'
  when 'Seven Pounds' then 'seven_pounds'
  when "Minority Report" then 'minority_report'
  when "The Fault in Our Stars" then 'etoiles_contraires'
  when "Rocky" then 'rocky'
  else
    montre = false
    film_id_string[0..-5].downcase
  end

  options = case sym
  when 'seven', 'seven_pounds' then '15'
  when 'her', 'minority_report', 'etoiles_contraires', 'rocky', 'TheMazeRunner2014' then '11'
  else '00'
  end

  values    = "#{film_id}, '#{sym}', \"#{titre}\", \"#{titre_fr}\", " +
    "#{annee}, '#{arr_pays.first}', \"#{realisateur}\", \"#{auteurs}\", '#{options}', #{Time.now.to_i}, #{Time.now.to_i}"
  req_inject = "INSERT INTO films (#{colonnes}) VALUES (#{values});"
  bdd_analyse.execute req_inject
  puts "INJECTÉ OK : #{req_inject}"
  # puts "#{req_inject}\n\n" if montre


  all_requests << req_inject
end

# puts "Toutes les requêtes d'injection"
# puts all_requests

# On injecte tout dans la base
# bdd_analyse.execute all_requests
