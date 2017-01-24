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

  # {Array} Liste des temps à laquelle cette IP s'est connectée
  # au site.
  attr_reader :times

  # {Array} Liste des instances Connexions::Connexion de
  # cette instance IP. Ces instances contiennent notamment
  # le temps et la route suivie
  def connexions
    @connexions ||= Array.new
  end

  # {Fixnum} Premier temps de connexion de cette IP dans la tranche
  # de temps.
  def start_time
    @start_time ||= begin
      st = connexions.first.time
      connexions.each { |con| con.time > st || st = con.time }
      st
    end
  end
  # {Fixnum} Dernier temps de connexion de cette IP dans la
  # tranche de temps étudiée
  def end_time
    @end_time ||= begin
      et = connexions.first.time
      connexions.each { |con| con.time < et || et = con.time }
      et
    end
  end

  def duree_connexion
    @duree_connexion ||= end_time - start_time
  end


  # Si l'IP correspond à un moteur de recherche, cette méthode
  # retourne l'instance SearchEngine de ce moteur de recherche
  # Sinon, retourne NIL.
  #
  # La méthode search_engine? se sert de cette méthode pour
  # savoir s'il y a un moteur de recherche.
  def search_engine
    @search_engine_searched || begin
      # C'est `search_engine?` qui définit @search_engine
      search_engine?
      @search_engine_searched = true
    end
    @search_engine
  end
end #/IP
end #/Connexions
