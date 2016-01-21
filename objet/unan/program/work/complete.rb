# encoding: UTF-8
=begin
On passe par ici pour marquer le travail terminé.
Mais il y a plein de vérification à faire.
=end

begin
  work_id = site.current_route.objet_id
  raise "Aucun travail n'est spécifié…" if work_id.nil?
  # L'user courant doit avoir un programme actif, sinon, ça n'a aucun sens
  raise "Piratage" unless user.program

  # On récupère le travail
  work = user.program.work( work_id )

  # Ce travail ne doit pas avoir déjà été marqué terminé
  raise "Ce travail est déjà marqué terminé…" if work.completed?

  # Le retirer de la liste des travaux où il se trouve
  # Et le marquer terminé.
  work.set_complete

  raise "Le travail devrait avoir été marqué terminé…" unless work.completed?

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente
redirect_to :last_route
