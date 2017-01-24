# encoding: UTF-8
=begin
Méthodes qui permettent de procéder au rapport
au site
=end
class Connexions
class Connexion
class << self

  # ---------------------------------------------------------------------
  #   Méthodes d'helper fonctionnelles
  # ---------------------------------------------------------------------
  # Méthode générale qui construit une ligne de résultat
  # avec le libellé +libelle+ et la valeur +value+
  def resline libelle, value
    "<span class='libelle'>#{libelle}</span><span class='value'>#{value}</span>\n"
  end

  # ---------------------------------------------------------------------
  #   Grandes parties du rapport
  # ---------------------------------------------------------------------

  def report_statistiques_generales
    @report << nombre_ips_differentes
    @report << nombre_de_search_engines
    @report << nombre_de_particuliers
    @report << nombre_de_routes
    @report << duree_totale_des_visites
    @report << duree_totale_des_visites_particuliers
  end

  # ---------------------------------------------------------------------
  #   Sous-méthodes d'helper
  # ---------------------------------------------------------------------

  # Retourne la ligne contenant le nombre d'IPs différentes
  def nombre_ips_differentes
    resline 'Nombre d’IPs', resultats[:per_ip].count
  end

  def nombre_de_search_engines
    sengine_list = Array.new
    resultats[:per_ip].each do |ip, dip|
      dip.search_engine? || next
      sengine_list << dip.search_engine.id
    end
    nb = sengine_list.uniq.count
    resline 'Nombre de moteurs de recherche', nb
  end

  def nombre_de_particuliers
    nb = 0
    resultats[:per_ip].each do |ip, dip|
      !dip.search_engine? || next
      !(ip == 'TEST') || next
      nb += 1
    end
    resline 'Nombre de particuliers', nb
  end

  def nombre_de_routes
    resline 'Nombre de routes', resultats[:per_route].count
  end

  def duree_totale_des_visites
    duree = 0
    resultats[:per_ip].each{|ip,dip| duree += dip.duree_connexion}
    resline 'Durée totale des visites', duree.as_horloge
  end

  def duree_totale_des_visites_particuliers
    duree = 0
    nombre_particuliers = 0
    resultats[:per_ip].each do |ip,dip|
      !dip.search_engine? || next
      duree += dip.duree_connexion
      nombre_particuliers += 1
    end
    duree_moy = duree / nombre_particuliers
    resline 'Durée visite particuliers', "#{duree.as_horloge} (#{duree_moy.as_horloge}/part.)"
  end

end #/<< self
end #/Connexion
end #/Connexions
