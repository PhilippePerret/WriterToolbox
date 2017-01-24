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
  def resline libelle, value, class_div = nil
    (
      libelle.in_span(class: 'libelle') +
      value.to_s.in_span(class: 'value')
    ).in_div(class: "dataline #{class_div}".strip)
  end

  # ---------------------------------------------------------------------
  #   Grandes parties du rapport
  # ---------------------------------------------------------------------

  def report_statistiques_generales
    @report << 'Statistiques générales'.in_h2
    @report << nombre_ips_differentes
    @report << nombre_de_particuliers
    @report << nombre_de_search_engines
    @report << nombre_de_routes
    @report << duree_totale_des_visites
    @report << duree_totale_des_visites_particuliers
  end

  # Ajouter au rapport les connexions qui ne correspondent pas
  # à un moteur de recherche et qui ont visité plus d'une page
  def report_multi_connexions
    @report << 'Multi-connexions'.in_h2
    @report << explication_multi_connexions
    @report << multi_routes_per_particuliers
  end

  # Ajouter au rapport les statistiques par route
  def report_statistiques_routes
    @report << 'Statistiques des routes'.in_h2
    @report << explication_statistiques_des_routes
    @report << statistiques_per_route
  end


  # Ajouter au rapport les statistiques par ensemble
  # (Narration, Filmodico, etc.)
  def report_statistiques_ensembles
    @report << 'Statistiques par sections'.in_h2
    @report << explication_statistiques_des_ensembles
    @report << statistiques_per_ensemble_per_duree
    @report << statistiques_per_ensemble_per_routes
  end


  # ---------------------------------------------------------------------
  #   Sous-méthodes d'helper
  # ---------------------------------------------------------------------

  # Retourne la ligne contenant le nombre d'IPs différentes
  def nombre_ips_differentes
    resline 'Nombre total d’IPs', resultats[:per_ip].count
  end

  def nombre_de_search_engines
    sengine_list = Array.new
    resultats[:per_ip].each do |ip, dip|
      dip.search_engine? || next
      sengine_list << dip.search_engine.id
    end
    nb = sengine_list.uniq.count
    resline 'Nombre de moteurs de recherche', nb, 'mleft'
  end

  def nombre_de_particuliers
    nb = 0
    resultats[:per_ip].each do |ip, dip|
      dip.particulier? || next
      nb += 1
    end
    resline 'Nombre de particuliers', nb, 'mleft'
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

  # ---------------------------------------------------------------------

  # Retourne une liste contenant les IPs de particulier qui
  # ont visité au moins deux pages du site (et qui ne sont pas
  # des moteurs de recherche, donc)
  #
  # La donnée se présente avec un libellé contenant l'IP et
  # le nombre de routes visitées.
  # Et en dessous la liste exacte des routes.
  def multi_routes_per_particuliers
    s = String.new

    # Pour compter le nombre de particuliers ayant visité plus
    # d'une route
    nombre_more_one_route = 0
    # Pour avoir la durée moyenne par particulier, on relève
    # la durée totale
    duree_totale_all_users = 0

    per_user_classed_by_duree = resultats[:per_user].collect{|ip,dip| dip}.sort_by{|dip| -dip.duree_connexion}

    # Pour n'avoir que ceux qui restent, pour récupérer les
    # plus longues et courtes connexions, etc.
    per_user_restants = Array.new

    per_user_classed_by_duree.each do |dip|
      # Il faut que ce soit un particulier pour qu'il soit
      # considéré
      dip.particulier? || next
      # Il faut au moins deux connexions pour que l'user
      # soit considéré
      dip.nombre_connexions > 1 || next
      # Il faut au moins deux routes différentes pour que
      # l'user soit considéré
      dip.nombre_routes > 1 || next
      # Il faut que l'user soit resté au moins 1 minute
      # sur le site
      dip.duree_connexion > 60 || next

      nombre_more_one_route += 1

      per_user_restants << dip

      div_user = dip.ip.in_span(class: 'ip_user')
      with_s = dip.nombre_routes > 1 ? 's' : ''
      div_user << "#{dip.nombre_routes} route#{with_s}".in_span(class: 'nombre_routes_user')
      div_user << "Durée totale : #{dip.duree_connexion.as_horloge}".in_span(class: 'duree_connexion')

      duree_totale_all_users += dip.duree_connexion

      div_user << dip.routes.sort_by{|iroute| - iroute.duree_reelle}.collect do |iroute|
        (
          iroute.duree_reelle.as_horloge.in_span(class: 'duree') +
          iroute.route
        ).in_li(class: 'user_route')
      end.join.in_ul(class: 'user_routes_list')
      s << div_user.in_div(class: 'user_div')
    end

    # Moyenne du temps de connexion
    duree_moy = (duree_totale_all_users / nombre_more_one_route).as_horloge

    # Pour connaitre la durée min et max de connexion
    plus_long_user = per_user_restants.first
    duree_max = plus_long_user.duree_connexion
    duree_max_nb_routes = plus_long_user.nombre_routes
    plus_court_user = per_user_restants.last
    duree_min = plus_court_user.duree_connexion
    duree_min_nb_routes = plus_court_user.nombre_routes

    stats_particuliers =
      resline('Nombre de particuliers (routes > 1)', nombre_more_one_route) +
      resline('Durée moyenne de connexion', duree_moy) +
      resline('Connexion la plus longue', "#{duree_max.as_horloge} (#{duree_max_nb_routes} routes)") +
      resline('Connexion la plus courte', "#{duree_min.as_horloge} (#{duree_min_nb_routes} routes)")


    return stats_particuliers.in_fieldset + s
  end


  # Note : la méthode permet aussi de calculer @per_ensemble
  def statistiques_per_route
    @statistiques_per_route ||= begin
      s = String.new

      # On boucle sur chaque user pour récupérer toutes les
      # routes.
      @routes       = Hash.new
      @per_ensemble = Hash.new
      resultats[:per_user].each do |ip, dip|
        # On passe les moteurs de recherche et test
        dip.particulier? || next
        dip.routes.each do |iroute|
          # Est-ce que cette route fait partie d'un ensemble ?
          if iroute.ensemble != nil
            @per_ensemble.key?(iroute.ensemble) || begin
              @per_ensemble.merge!(iroute.ensemble => {duree: 0, routes: Array.new})
            end
          end
          @routes.key?(iroute.route) || begin
            # Une route pas encore connue
            @routes.merge!(iroute.route => 0)
          end
          # On ajoute la durée à cette route
          @routes[iroute.route] += iroute.duree_reelle
          if iroute.ensemble != nil
            @per_ensemble[iroute.ensemble][:routes] << iroute.route
          end
        end
      end

      # On bouche maintenant sur toutes les routes
      s <<
        @routes.sort_by{|r, d| - d}.collect do |route, duree|
          (
            duree.as_horloge.in_span(class: 'duree fright') +
            route.in_span(class: 'route')
          ).in_li(class: 'liroute')
        end.join.in_ul(id: 'statistiques_route')

      # Pour renvoi
      s
    end
  end

  def statistiques_per_ensemble_per_duree
    @per_ensemble || statistiques_per_route

    # On commence par calculer la durée de chaque ensemble
    @per_ensemble.each do |ensemble_id, densemble|
      densemble[:routes].each do |route|
        densemble[:duree] += @routes[route]
      end
    end

    'Classement par durée'.in_h3 +
    @per_ensemble.sort_by{|eid, dens| -dens[:duree]}.collect do |ens_id, ens_data|
      ens_name = Connexions::Connexion::Route::ENSEMBLE[ens_id][:hname]
      nb_routes = ens_data[:routes].count
      with_s = nb_routes > 1 ? 's' : ''
      (
        ens_name.in_span(class: 'ensemble_name') +
        "#{nb_routes} route#{with_s}".in_span(class: 'ensemble_nombre_routes') +
        ens_data[:duree].as_horloge.in_span(class: 'duree')
      ).in_div(class: 'data_ensemble')
    end.join.in_div(class: 'statistiques_ensemble')
  end

  def statistiques_per_ensemble_per_routes
    'Classement par nombre de routes'.in_h3 +
    @per_ensemble.sort_by{|eid, dens| -dens[:routes].count}.collect do |ens_id, ens_data|
      ens_name = Connexions::Connexion::Route::ENSEMBLE[ens_id][:hname]
      nb_routes = ens_data[:routes].count
      with_s = nb_routes > 1 ? 's' : ''
      (
        ens_name.in_span(class: 'ensemble_name') +
        "#{nb_routes} route#{with_s}".in_span(class: 'ensemble_nombre_routes')
        # ens_data[:duree].as_horloge.in_span(class: 'duree')
      ).in_div(class: 'data_ensemble')
    end.join.in_div(class: 'statistiques_ensemble')

  end

  # ---------------------------------------------------------------------
  #   Textes d'explication des parties
  # ---------------------------------------------------------------------

  # Retourne le texte d'explication de la section multi-connexions
  def explication_multi_connexions
    t = <<-HTML
Cette partie présente seulement les connexions hors moteurs de recherche des particuliers ayant visité au moins 2 pages et sont restés plus de 1 minute sur le site.
    HTML
    t.in_div(class: 'explication')
  end
  def explication_statistiques_des_routes
    t = <<-HTML
Cette partie présente les statistiques par routes visitées, de la plus visitées à la moins visitée, en ne tenant compte que des visites de particuliers, pas des moteurs de recherche connus.
    HTML
    t.in_div(class: 'explication')
  end
  def explication_statistiques_des_ensembles
    t = <<-HTML
Les statistiques par section montre la durée de visite pour chaque grand ensemble qu'est la collection Narration, les citations, etc.
    HTML
    t.in_div(class: 'explication')
  end

end #/<< self
end #/Connexion
end #/Connexions
