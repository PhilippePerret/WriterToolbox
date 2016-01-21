# encoding: UTF-8
=begin

Class Unan::Program::Work
-------------------------------
Un travail du programme Un An Un Script exécuté par un auteur.
Il renvoie directement à un travail absolu dont il est l'instance
pour l'auteur.

Note : Pour voir les données absolues du travail, cf. la classe
AbsWork.
=end
class Unan
class Program
class Work

  include MethodesObjetsBdD

  # {Fixnum} ID du programme dans la table des travaux
  # propre au programme.
  attr_reader :id

  # {Unan::Program} Program auquel appartient le travail
  attr_reader :program

  # Instanciaiton du Work
  # +wid+ Identifiant du travail. Note : CE N'EST PLUS l'id
  # du travail absolu. Note : Il est nil à l'instanciation
  def initialize program, wid
    @program  = program
    @id       = wid
  end

  def set_complete
    # Il faut le retirer des listes
    # On ajoute la clé :works pour traiter aussi la liste
    # :works_ids à laquelle appartient forcément le travail
    # puisque cette liste contient tous les travaux courants
    liste_retraits = Array::new
    hliste = Unan::Program::AbsWork::CODES_BY_TYPE
    hliste.merge(works: nil).each do |lid, ldata|
      key_list = "#{lid}_ids".to_sym
      liste = program.auteur.get_var(key_list, Array::new).uniq
      if liste.include? id
        liste.delete( id )
        user.set_var(key_list => liste )
        liste_retraits << key_list
      end
    end
    if (OFFLINE || user.admin?) && liste_retraits.count < 2
      error "Bizarrement, le travail n'a été retiré que de la liste #{liste_retraits.pretty_join}… Il aurait dû être retiré de deux listes."
    end
    set(status: 9, updated_at: NOW)
    flash "Travail #{id} marqué terminé."
  end

  # {BdD::Table} Table contenant les travaux propres de l'user, c'est-à-dire
  # ses résultats divers sur les travaux absolus.
  # Noter que c'est la méthode `program.table_works` qui doit être
  # impérativement invoquée pour procéder à la construction de
  # la table si elle n'existe pas encore.
  def table
    @table ||= program.table_works
  end

end #/Work
end #/Program
end #/Unan
