# encoding: UTF-8
=begin

  Méthode concernant la commande Curl

=end
class TestedPage
  # Soumet la command CURL et retourne le résultat (brut, c'est
  # dans la méthode appelante que l'encodage sera forcé, par exemple
  # et que le code sera testé/validé)
  def retour_curl_commande
    `#{curl_command}`
  end

  # Fabrication de la commande CURL
  #
  # L'url peut contenir des données, etc., que la commande fait
  # passer dans --data
  def curl_command
    @curl_command ||= begin
      justurl, data = url.split('?')
      if data.nil?
        "curl -s #{justurl}"
      else
        "curl -s --data \"#{data}\" #{justurl}"
      end
    end
  end

  # Retourne la commande Curl pour obtenir l'entête seulement
  # d'une page hors-site.
  # Ici, avec -I, on ne peut pas passer de --data, donc il n'y a
  # plus qu'à espérer que ça fonctionne.
  def curl_command_header_only
    @curl_command_header_only ||= begin
      justurl, data = url.split('?')
      "curl -I #{url}"
      # if data.nil?
      # else
      #   "curl -I --data \"#{data}\" #{justurl}"
      # end
    end
  end

end #/TestedPage
