# encoding: UTF-8
=begin

Module pour démarrer un travail, c'est-à-dire pour que l'auteur
indique qu'il a pris en compte ce travail.
C'est ce module qui crée véritablement l'instance Unan::Program::Work
qui n'existait que virtuellement auparavant (ce qui a permis de simplifier
la procédure de changement de jour-programme de l'auteur)
=end
raise_unless user.unanunscript? || user.admin?

class Unan
class Program
class Work

  attr_reader :data2save
  def data2save= value; @data2save = value end

  # La méthode qui crée le work dans la table
  def create
    @id = table.insert( data2save )
  end


end #/Work
end #/Program
end #/Unan

begin

  # L'user courant doit avoir un programme actif, sinon, ça n'a aucun sens
  raise "Piratage" unless user.program


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
  work = Unan::Program::Work::new( user.program, nil )
  work.data2save= {
    program_id:   user.program.id,
    abs_work_id:  abs_work_id,
    abs_pday:     work_pday,
    status:       1,  # pour le marquer démarré
    options:      "",
    created_at:   NOW,
    updated_at:   NOW
  }
  debug "work.data2save : #{work.data2save.pretty_inspect}"
  work.create

  raise "Le travail devrait avoir été marqué démarré…" unless work.started?

rescue Exception => e
  error e.message
end
# Rediriger vers la page précédente, certainement l'onglet tâches du
# centre de travail.
redirect_to :last_route
