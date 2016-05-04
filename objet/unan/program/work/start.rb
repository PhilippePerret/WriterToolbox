# encoding: UTF-8
=begin

Module pour démarrer un travail, c'est-à-dire pour que l'auteur
indique qu'il a pris en compte ce travail.
C'est ce module qui crée véritablement l'instance Unan::Program::Work
qui n'existait que virtuellement auparavant (ce qui a permis de simplifier
la procédure de changement de jour-programme de l'auteur)
=end
raise_unless user.unanunscript? || user.admin?

begin
  # L'user courant doit avoir un programme actif, sinon, ça n'a aucun sens
  raise "Piratage" unless user.program

  require './objet/unan/lib/module/work/create.rb'

  abs_work_id = param(:awork).to_i
  raise "Ce work absolu est impossible" if abs_work_id == 0
  work_pday   = param(:wpday).to_i
  raise "Le jour-programme du work doit être défini." if work_pday == 0

  # Il faut vérifier que ce jour-programme définit bien ce travail
  # absolu. Dans le cas contraire, c'est un petit malin qui essaie
  # de passer en force
  ipday = Unan::Program::AbsPDay::get(work_pday)
  unless ipday.works(:as_ids).include?( abs_work_id)
    raise "Aucun travail de ce type dans le jour-programme spécifié"
  end

  # Instance du nouveau travail
  work = create_new_work_for_user(
    user:         user,
    abs_work_id:  abs_work_id,
    indice_pday:  work_pday,
  )

  raise "Le travail devrait avoir été marqué démarré…" unless work.started?

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente, certainement l'onglet tâches du
# centre de travail.
redirect_to :last_route
