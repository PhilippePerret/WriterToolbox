# encoding: UTF-8
=begin
  Instance Connexions::Connexion
=end
class Connexions
class Connexion

  # {Fixnum} Le time en secondes de la connexion
  attr_reader :time

  # {String} La route demandée par la connexion
  attr_reader :route

  # {String} l'IP ayant générée cette connexion
  attr_reader :ip

end #/Connexion
end #/Connexions
