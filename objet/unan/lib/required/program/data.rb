# encoding: UTF-8
=begin

Méthode de data du programme

=end
class Unan
class Program

  # ID du programme (dans la table Unan::table_programs)
  attr_reader :id

  # La propriété la plus importante du programme : l'auteur
  # Note : on obtient son instance par `auteur`
  attr_reader :auteur_id
  attr_reader :created_at
  attr_reader :updated_at

  # ID de l'étape dans la table `etapes` du programme propre
  # Note : ne correspond pas à un numéro d'étape, mais à un ID
  attr_reader :etape_id

  # {Fixnum} Le nombre de points
  # L'idéal est de commencer à 0 et d'arriver à 10000 (en fait, 9999
  # puisque la donnée est sur quatre chiffres) en fin de scénario.
  # Ces points font partie de l'aspect ludique du programme.
  attr_reader :points

  def get key
    Unan::table_programs.get(id, colonnes:[key])[key]
  end
  def set hdata
    Unan::table_programs.set(id, hdata)
  end

  # ---------------------------------------------------------------------
  #   Data du programme
  # ---------------------------------------------------------------------
  # {User} Auteur du programme
  def auteur        ; @auteur ||= User::get(auteur_id)  end
  # {String} Options du programme
  def options       ; @options ||= get(:options) || ""  end
  # {Fixnum} Date de création (timestamp)
  def created_at    ; @created_at ||= get(:created_at)  end

end # /Program
end # /Unan
