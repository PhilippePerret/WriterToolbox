# encoding: UTF-8
=begin

Instances Unan
--------------
Gestion d'un programme en particulier
C'est donc le programme suivi par un user inscrit et à jour de ses paiements.

=end
class Unan

  # La propriété la plus importante du programme : l'auteur
  # lui-même. Il est enregistré.
  # Note : on obtient son instance par `auteur`

  attr_reader :auteur_id
  attr_reader :options
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

  def initialize id = nil

  end

  def auteur
    @auteur ||= User::get(auteur_id)
  end

end
