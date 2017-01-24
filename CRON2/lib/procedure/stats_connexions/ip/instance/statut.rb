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

  def search_engine?
    @is_search_engine === nil && begin
      @search_engine = self.class.get_search_engine_with_ip(ip)
      @is_search_engine = @search_engine != nil
    end
    @is_search_engine
  end


end #/IP
end #/Connexions
