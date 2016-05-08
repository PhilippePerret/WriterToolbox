# encoding: UTF-8
=begin

Script de récupération des données de tâches pour créer l'archive

DISTANT:
site.require_objet('admin');::Admin::require_module('taches');::Admin::table_taches_cold.delete(287)
affiche table site_hot.todolist

LOCAL :
site.require_objet('admin');::Admin::require_module('taches');::Admin::table_taches_cold.delete(287)
affiche table site_cold.todolist

=end
require './lib/required'
User::current = User::get(1)
app.session['user_id'] = 1

begin
  puts "Chargement objet admin"
  site.require_objet 'admin'
  puts "Chargement module taches d'Admin"
  ::Admin::require_module 'taches'
  puts ::Admin::table_taches.bdd.path.to_s
  puts ::Admin::table_taches_cold.bdd.path.to_s
  liste_taches_hot_to_kill = Array::new
  ::Admin::table_taches.select.each do |tid, tdata|
    # On doit passer toutes les tâches non terminées
    next if tdata[:state] < 9
    
    
    # On doit supprimer certaines données et en ajouter d'autres
    tdata_cold = tdata.dup
    tdata_cold.delete(:state)
    tdata_cold.delete(:echeance)
    tdata_cold.merge!(ended_at: tdata_cold.delete(:updated_at))
    # Créer la donnée en archives (noter que l'ID reste le même)
    ::Admin::table_taches_cold.insert(tdata_cold)
    
    # Mémoriser cette tâche à détruire
    liste_taches_hot_to_kill << tid
    
    
    # puts "NOUVELLES DONNÉES COLD :\n#{tdata_cold.pretty_inspect}"
    # break
  end
  
  puts "Tache hot à détruire : #{liste_taches_hot_to_kill.join(', ')}"
  ::Admin::table_taches.delete(where:"id IN (#{liste_taches_hot_to_kill.join(',')})")
  
rescue Exception => e
  puts "# ERREUR : #{e.message}"
  puts e.backtrace.join("\n")
end