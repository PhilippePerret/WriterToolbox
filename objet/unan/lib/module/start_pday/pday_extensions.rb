# encoding: UTF-8
class Unan
class Program
class PDay

  # Le message de dépassement ou de non dépassement qui est placée
  # après la liste des nouveaux travaux
  attr_accessor :message_depassement

  # Les messages ajoutés au mail, pour faire la liste des travaux
  # du jour-programme
  attr_reader :messages_mail
  # Les alertes ajoutés au mail
  attr_reader :alertes_mail
  
  # {Array of String} Liste des nouveaux travaux (titres), dans
  # des LI
  attr_accessor :liste_nouveaux_travaux
  # {Array of String} Liste des travaux courants (hors nouveaux) dans
  # des LI
  attr_accessor :liste_travaux_courants

  def init_messages_lists
    @messages_mail          = Array::new
    @alertes_mail           = Array::new
    @liste_nouveaux_travaux = Array::new
    @liste_travaux_courants = Array::new
  end

  # Pour ajouter un message au mail
  def add_message_mail mess
    @messages_mail << mess
  end

  # Pour ajouter des alertes dans le mail, messages à placer
  # en premier dans le message
  def add_alerte_mail mess
    @alertes_mail << mess
  end

end # /PDay
end # /Program
end # /Unan
