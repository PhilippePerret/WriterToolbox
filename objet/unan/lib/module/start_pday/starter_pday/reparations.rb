# encoding: UTF-8
=begin
Ce module contient toutes les réparations qui peuvent être opérées
au cours du travail du cron-job
=end
class Unan
class Program
class StarterPDay


  # Tente de réparer la variable :current_pday de l'auteur, quand elle
  # est nil (cela est arrivé au cours des tests avec Benoit, peut-être à
  # cause d'un jour-programme effacé au cours des tests précédents).
  # On regarde dans la table des pdays de l'auteur pour prendre le dernier
  # numéro qui y a été rentré.
  # Note : Il suffit de faire une recherche sur le nom de cette méthode
  # pour trouver où elle est utilisée.
  def reparer_error_current_pday_nil
    curpday = nil
    begin
      curpday = auteur.table_pdays.select(limit:1, order:"id DESC", colonnes:[]).keys.first
    rescue Exception => e
      log "# ERROR dans `Unan::Program::StartPDay::reparer_error_current_pday_nil` : #{e.message}"
      log "# current_pday est donc mis artificiellement à 1"
    end
    auteur.set_var(:current_pday, curpday || 1)
  end



end #/StarterPDay
end #/Program
end #/Unan
