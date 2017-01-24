# encoding: UTF-8
class Connexions
class SearchEngine

  attr_reader :human_id
  # {Hash} Les données telles que définies dans le fichier
  # known_ips.rb
  attr_reader :data
  # Les données dispatchées
  attr_reader :id, :pseudo, :short_pseudo, :ips
  # Alias
  alias :name :pseudo
  alias :short_name :short_pseudo

  # Récupération des données et dispatch
  # La méthode est appelée dès l'initialisation
  def get_data
    @data = SEARCH_ENGINES_IPS_LIST[human_id]
    @data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

end #/SearchEngine
end #/Connexions
