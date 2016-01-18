# encoding: UTF-8
class Unan
class Program
class PDay

  # Les messages ajoutés au mail, pour faire la liste des travaux
  # du jour-programme
  attr_reader :messages_mail
  # {Array of String} Liste des nouveaux travaux (titres), dans
  # des LI
  attr_accessor :liste_nouveaux_travaux
  # {Array of String} Liste des travaux courants (hors nouveaux) dans
  # des LI
  attr_accessor :liste_travaux_courants

  def init_messages_lists
    @messages_mail          = Array::new
    @liste_nouveaux_travaux = Array::new
    @liste_travaux_courants = Array::new
  end

  # Pour ajouter un message au mail
  def add_message_mail mess
    @messages_mail << mess
  end

end # /PDay
end # /Program
end # /Unan
