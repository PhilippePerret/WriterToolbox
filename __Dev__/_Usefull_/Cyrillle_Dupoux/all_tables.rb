# encoding: UTF-8
=begin

  Pour voir toutes les tables de l'inscrit.

=end
require './lib/required'
require_relative 'mail_auteur.rb' # => MAIL_USER
require_relative 'required'

duser = User.table.get(where: {mail: MAIL_USER })
user_id = duser[:id]
pseudo = duser[:pseudo]

# puts duser.inspect
dprogram = table_programs.get(where: {auteur_id: user_id })
# puts dprogram.inspect

puts "AUTEUR : #{duser[:pseudo]}"
puts "RYTHME : #{dprogram[:rythme]}"
puts "JOUR COURANT AUTEUR : #{dprogram[:current_pday]} (depuis le #{dprogram[:current_pday_start].as_human_date(true, true, ' ')})"

# ---------------------------------------------------------------------
#   AFFICHAGE DES TRAVAUX 
# ---------------------------------------------------------------------

if table_works(user_id).exist?
  puts "\n\n\n" + '-'*80
  puts "___ LISTE DES WORKS DE #{pseudo} (#{table_works.count}) ___"
  works_done    = []
  works_undone  = []
  table_works.select.each do |hw|
    if hw[:status] == 9
      works_done << hw
    else
      works_undone << hw
    end
  end
  puts "\n\n______ TRAVAUX ACHEVÉS ______\n"
  puts works_done.collect{|h| work_card h}.join("\n")
  puts "\n\n______ TRAVAUX INACHEVÉS _____\n"
  puts works_undone.collect{|h| work_card h}.join("\n")
else
  puts "# ERREUR : La table des travaux n'existe pas."
end
