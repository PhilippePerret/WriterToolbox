# encoding: UTF-8
=begin
Module pour démarrer le module ou plus exactement permettant à l'auteur
d'indiquer qu'il a pris en compte ce travail.
C'est le bouton "Démarrer ce travail", sur le bureau de l'auteur, qui lui
permet d'appeler ce module qui va passer le statut du work de 0 à 1
=end
raise_unless user.unanunscript? || user.admin?

begin
  work_id = site.current_route.objet_id
  raise "Aucun travail n'est spécifié…" if work_id.nil?
  # L'user courant doit avoir un programme actif, sinon, ça n'a aucun sens
  raise "Piratage" unless user.program

  # On récupère le travail
  work = user.program.work( work_id )

  # Ce travail ne doit pas avoir déjà été marqué terminé
  raise "Ce travail est déjà marqué démarré…" if work.started?

  # Marquer ce travail terminé en faisant tout ce qu'il y a à
  # faire le concernant.
  work.set_started

  raise "Le travail devrait avoir été marqué démarré…" unless work.started?

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente, certainement l'onglet tâches du
# centre de travail.
redirect_to :last_route
