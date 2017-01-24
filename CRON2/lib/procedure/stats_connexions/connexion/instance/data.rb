# encoding: UTF-8
=begin
  Instance Connexions::Connexion
=end
class Connexions
class Connexion

  # {Fixnum} Le time en secondes de la connexion
  attr_reader :time

  # {Fixnum} Le temps de fin en secondes de la connexion
  # Il est défini au début de l'analyse dès qu'un temps
  # suivant est produit
  attr_accessor :end_time

  # {String} La route demandée par la connexion
  attr_reader :route

  # {String} l'IP ayant générée cette connexion
  attr_reader :ip

  # Durée de cette connexion
  # ------------------------
  # Soit @end_time est défini et on peut vraiment calculer
  # la durée de cette connexion, soit on met 10 secondes
  def duree
    @duree ||= begin
      end_time.nil? ? 10 : (end_time - time)
    end
  end

end #/Connexion
end #/Connexions
