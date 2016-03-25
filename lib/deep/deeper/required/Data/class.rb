# encoding: UTF-8
=begin
Module de traitement de données spéciales.

Ce module a été inauguré pour le traitement des données des
commandes de console qui peuvent être mises sous la forme :
    `prop:valeur de la prop autreprop: autre valeur de l'autre propre etc.`
    Cf. semicolon_data_in
=end
class Data
class << self

  # @usage :
  #     hash_data = Data::by_semicolon_in line_data_string
  #
  # Reçoit une chaine de données qui ressemble à :
  #   "pour:Phil le: auj tache: Ceci est la tache à exécuter : pour voir."
  # et retourne un Hash contenant :
  #   {
  #     pour: "Phil", le: "auj", tache: "Ceci est etc."
  #   }
  # Les clés (:pour, :le, etc.) doivent :
  #     * ne contenir que des lettres maj/min et des chiffres
  #     * doivent être collées aux ":"
  #     * doivent être précédés par une espace
  def by_semicolon_in data_str
    # On ajoute une balise de fin "fin:" pour que l'expression
    # régulière puisse capter le dernier élément de data_str
    data_str = " #{data_str} fin:"
    # Le hash de données qui sera revoyé
    hdata = Hash::new
    data_str.scan(/ ([a-zA-Z0-9]+)\:(.*?)(?= [a-zA-Z0-9]+\:)/).to_a.each do |paire|
      key, value = paire
      hdata.merge!(key.to_sym => value.strip.freeze)
    end
    return hdata
  end

end #/<< self
end #/Data
