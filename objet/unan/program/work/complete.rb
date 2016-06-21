# encoding: UTF-8
=begin

On passe par ici pour marquer le travail terminé. Donc depuis le
bureau central du programme, en cliquant sur le bouton
"Marquer ce travail fini" qui se trouve sous chaque travail.

De nombreuses vérifications sont à faire.
=end

begin

  # L'user courant doit avoir un programme actif, sinon, ça n'a aucun sens
  raise "Piratage" unless user.program

  work_id = site.current_route.objet_id
  raise "Aucun travail n'est spécifié…" if work_id.nil?
  debug "[complete.rb] work_id = #{work_id}"

  # On récupère le travail
  work = ( user.program.work work_id )
  debug "[complete.rb] work.status = #{work.status.inspect}"

  # Ce travail ne doit pas avoir déjà été marqué terminé
  !work.completed? || raise('Ce travail est déjà marqué terminé…')

  # Marquer ce travail terminé
  work.set_complete

  work.completed? || raise('Le travail devrait avoir été marqué terminé…')

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente
redirect_to :last_route
