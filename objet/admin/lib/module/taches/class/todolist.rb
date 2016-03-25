# encoding: UTF-8
class Admin
class Todolist
class << self

  # Retourne la pastille à coller en haut de page indiquant à
  # un administrateur le nombre de tâches qu'il a à faire
  def pastille_taches_administrator
    todolist  = new(admin_id: user.id)
    nombre_taches_overl = 0
    nombre_taches_today = 0
    nombre_taches_later = 0
    nombre_taches_nodat = 0
    taches    = todolist.taches
    nombre_taches = taches.count

    # S'il n'y a aucune tache on peut retourner un string vide, ce
    # qui signifie qu'aucune pastille ne sera affichée.
    return "" if nombre_taches == 0
    taches.each do |itache|
      if itache.echeance.nil?
        nombre_taches_nodat += 1
      elsif itache.echeance < Today.start
        nombre_taches_overl += 1
      elsif itache.today?
        nombre_taches_today += 1
      else
        nombre_taches_later += 1
      end
    end

    # La couleur de la pastille va dépendre de l'échéance
    bkg = if nombre_taches_overl > 0
      'red'
    elsif nombre_taches_today > 0
      'green'
    else
      'blue'
    end

    mess = Array::new
    mess << "#{tache_s nombre_taches_overl} en retard." if nombre_taches_overl > 0
    mess << (nombre_taches_today > 0 ? "#{tache_s nombre_taches_today} à effectuer aujourd'hui" : "Aucune tâche à effectuer aujourd'hui")
    mess << "#{tache_s nombre_taches_later} à effectuer plus tard" if nombre_taches_later > 0
    mess << "#{tache_s nombre_taches_nodat} sans échéance" if nombre_taches_nodat > 0
    mess = mess.pretty_join + " Cliquez pour les voir."

    "#{nombre_taches}".in_a(href: "admin/todo_list", id:"pastille_taches_admin", style:"background-color:#{bkg}", title:mess)
  end

  def tache_s nombre
    "#{nombre} tâche#{nombre > 1 ? 's' : ''}"
  end

end #/<<self
end #/Todolist
end #/Admin
