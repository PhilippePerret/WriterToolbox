# encoding: UTF-8
=begin

Module pour démarrer un travail, c'est-à-dire pour que l'auteur
indique qu'il a pris en compte ce travail.
C'est ce module qui crée véritablement l'instance Unan::Program::Work
qui n'existait que virtuellement auparavant (ce qui a permis de simplifier
la procédure de changement de jour-programme de l'auteur)
=end
raise_unless user.unanunscript? || user.admin?

require './objet/unan/lib/module/work/create.rb'
awork_id  = site.current_route.objet_id.to_i
work_pday = param(:wpday).to_i
Unan::Program::Work.start_work(user, awork_id, work_pday)

# Rediriger vers la page précédente, certainement l'onglet tâches du
# centre de travail.
redirect_to :last_route
