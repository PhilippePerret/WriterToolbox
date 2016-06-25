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

  require './objet/unan/lib/module/work/create.rb'

  # Dans la route
  awork_id  = site.current_route.objet_id.to_i
  work_pday = param(:wpday).to_i

  # Checks
  awork_id > 0 || raise('L’ID du work absolu est impossible.')
  work_pday > 0   || raise('Le jour-programme du work doit être défini.')

  # Il faut que ce jour-programme soit inférieur ou égal au jour-programme
  # courant de l'auteur, sinon c'est impossible
  work_pday <= user.program.current_pday || raise('Ce jour-programme est impossible, voyons…')

  # Il faut vérifier que ce jour-programme définit bien ce travail
  # absolu. Dans le cas contraire, c'est un petit malin qui essaie
  # de passer en force
  ipday = Unan::Program::AbsPDay::get(work_pday)
  lworks = ipday.works(:as_ids)
  lworks.include?( awork_id) || raise("Aucun travail d'ID ##{awork_id} le #{work_pday}<sup>e</sup> jour-programme…")

  # Instance du nouveau travail
  work = create_new_work_for_user(
    user:         user,
    abs_work_id:  awork_id,
    indice_pday:  work_pday,
  )
  if work != nil
    work.started? || raise('Le travail devrait avoir été marqué démarré…')
  else
    # C'est une recréation accidentelle du travail, il ne faut rien faire
  end

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente, certainement l'onglet tâches du
# centre de travail.
redirect_to :last_route
