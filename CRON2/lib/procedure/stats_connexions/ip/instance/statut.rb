# encoding: UTF-8
# encoding: UTF-8
=begin

  Instance Connexions::IP
  -----------------------
  Pour le traitement d'un IP en particulier
  Méthodes d'helper.

=end
class Connexions
class IP


  # Renvoie true si cet IP correspond à un particulier, i.e. pas
  # un moteur de recherche et pas l'adresse de test.
  def particulier?
    @is_particulier === nil && begin
      @is_particulier = (ip != 'TEST' && !search_engine? )
    end
    @is_particulier
  end

  def search_engine?
    @is_search_engine === nil && begin
      @search_engine = self.class.get_search_engine_with_ip(ip)
      @is_search_engine = @search_engine != nil
    end
    @is_search_engine
  end


end #/IP
end #/Connexions
