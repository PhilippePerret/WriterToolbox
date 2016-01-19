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
  # +wid+ Identifiant du travail absolu qui sert aussi d'id
  # pour le travail propre au programme ici.
  def initialize program, wid
    @program  = program
    @id       = wid
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
