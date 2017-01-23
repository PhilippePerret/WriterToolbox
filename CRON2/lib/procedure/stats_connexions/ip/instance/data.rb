# encoding: UTF-8
# encoding: UTF-8
=begin

  Instance Connexions::IP
  -----------------------
  Pour le traitement d'un IP en particulier

=end
class Connexions
class IP

  # Adresse IP de cette instance Connexions::IP
  attr_reader :ip

  # {Array} Liste des instances Connexions::Connexion de
  # cette instance IP. Ces instances contiennent notamment
  # le temps et la route suivie
  attr_reader :connexions

  # {Array} Liste des temps à laquelle cette IP s'est connectée
  # au site.
  attr_reader :times


end #/IP
end #/Connexions
