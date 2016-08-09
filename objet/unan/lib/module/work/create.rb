# encoding: UTF-8
=begin

Module pour créer un travail (Unan::Program::Work)

=end

# Méthode à appeler pour créer le travail et le marquer
# démarré.
#
# RETURN L'instance Unan::Program::Work créée Ou NIL si
# le travail existait déjà.
#
# +data+ doit impérativement définir :
#   :user_id ou :user     Auteur de ce travail
#   :abs_work_id        {Fixnum}    Identifiant du travail absolu
#   :indice_pday        {Fixnum}    Indice du PDay de ce travail
#
def create_new_work_for_user wdata
  auteur = wdata[:user] || User.get(wdata[:user_id])

  # Avant de créer le travail, il faut s'assurer qu'il
  # n'existe pas déjà, ce qui se produit lorsque l'user
  # recharche sa page
  awork_id = wdata[:abs_work_id]
  progr_id = auteur.program.id
  pday     = wdata[:indice_pday]

  where = {
    program_id: progr_id, abs_work_id: awork_id, abs_pday: pday
  }
  if auteur.table_works.count(where: where) > 0
    error 'Admin, je ne recrée pas le travail après rechargement de la page.' if OFFLINE
    return nil
  end

  # Pour le type de travail
  awork = Unan::Program::AbsWork::get(awork_id)
  # Création de l'instance et enregistrement
  iwork = Unan::Program::Work.new( auteur.program, nil )
  iwork.data2save= {
    program_id:   progr_id,
    abs_work_id:  awork_id,
    abs_pday:     pday,
    status:       1,  # pour le marquer démarré
    options:      "#{awork.type_w.rjust(2,'0')}",
    created_at:   NOW,
    updated_at:   NOW
  }
  # debug "work.data2save : #{work.data2save.pretty_inspect}"
  iwork.create

  return iwork
end

# ---------------------------------------------------------------------
#   Extension de la class Unan::Program::Work pour la création
#   du travail
# ---------------------------------------------------------------------
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
