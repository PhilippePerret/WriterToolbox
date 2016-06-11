# encoding: UTF-8
=begin

Module pour faire un rapport à l'administration sur les connexions.
En fonction des préférences de fréquences, ce rapport se fait toutes les
heures, tous les jours, toutes les semaines, etc.

Ce module doit être STANDALONE

=end
class SiteHtml
class Connexions
class << self

  def log str
    safed_log "\t\t\t#{str}"
  end

  # = main =
  #
  # @usage SiteHtml::Connexions::resume_connexions
  #
  # Méthode principale qui, en fonction des réglages de
  # fréquence, fait un résumé des connexions à l'administrateur.
  #
  # Cette méthode est appelée TOUTES LES HEURES par le cron
  # horaire mais elle ne s'exécute vraiment qu'en fonction des
  # préférences définies dans ./
  #
  def resume
    # On regarde s'il faut faire le rapport
    log "   rapport_needed? : #{rapport_needed?.inspect}"
    if false == rapport_needed?
      log "   = Aucune connexion par IP à rapporter"
      return
    end
    log "* Résumé des connexions par IP"
    log ". = #{File.expand_path('.')}"
    ireport = new
    ireport.prepare_rapport
    ireport.build_report
    if ireport.has_connexions?
      ireport.consigne_report
      ireport.send_report
    end
    ireport.reset_databases_connexions
    log "  = Résumé des connexions OK"
    log "<- SiteHtml::Connexions::resume"
  rescue Exception => e
    error_log e, "# ERREUR AU COURS DU RAPPORT DE CONNEXIONS"
  end

  # Retourne TRUE s'il faut faire le rapport (en fonction de
  # la fréquence demandée)
  def rapport_needed?
    # On utilise un truc assez sale ici, c'est de lire le fichier
    # qui définit la fréquence en code brut
    p = SuperFile::new('./objet/site/config.rb')
    now = Time.now
    premiere_heure = ( now.hour == 0 )
    code = p.read
    freq = code.scan(/^site\.alert_apres_login ?=(.*?)$/).to_a[0][0]
    freq = freq.strip unless freq.nil?
    safed_log "Fréquence de rapport connexion : #{freq.inspect}"
    case freq
    when nil
    when ":tout_de_suite", ":now"
      false # c'est géré autrement
    when ":one_an_hour", ":une_par_heure"
      return true # puisque c'est le cron horaire
    when ':twice_a_day', 'deux_par_jour'
      return premiere_heure || now.hour == 12
    when ":one_a_day", ":une_page_jour"
      # Retourne true si on est dans la première heure du jour
      return premiere_heure
    when ":one_a_week", ":une_par_semaine"
      return now.wday == 1 && premiere_heure
    when ":one_a_month", ":une_par_mois"
      return now.mday == 1 && premiere_heure
    else
      return false
    end
  end

end # << self SiteHtmlConnexions

# ---------------------------------------------------------------------
# Instance
# ---------------------------------------------------------------------

  attr_reader :report

  def initialize
    @report = Hash::new
    @report = {
      by_ip:    Hash::new,
      message:  nil,
      titre:    nil
    }
  end

  def log m
    self.class.log m
  end

  # Retourne TRUE si des connexions ont été trouvées. Dans le
  # cas contraire, aucun mail n'est envoyé et aucun rapport
  # n'est à consigner.
  def has_connexions?
    report[:by_ip].count > 0
  end

  # Préparation du rapport
  # Notamment, on fait une copie du dossier
  # des connexions
  def prepare_rapport
    # On commence par copier toutes les bases de données
    folder_connexions_report.remove if folder_connexions_report.exist?
    folder_connexions_report.build
    Dir["#{folder_connexions}/*.db"].each do |p|
      FileUtils::cp p, File.join(folder_connexions_report.to_s, File.basename(p))
      File.unlink p
    end
  end

  # Construction du rapport
  def build_report
    recolte_connexions_by_ip
    rationalise_connexions
    build_message_admin
  end

  # On construit le message pour l'administrateur, qui va lui
  # rapporter toutes les connexions qui ont eu lieu.
  def build_message_admin
    titre = "Rapport #{ONLINE ? 'ONLINE' : 'OFFLINE'} des connexions du #{Time.now}"

    # Le message complet à construire
    mess = ''

    ip_entete     = "IP".ljust(20)
    nb_entete     = "Nb".ljust(4)
    duree_entete  = "Durée".ljust(5)
    whois_entete  = "Whois".ljust(30)
    from_entete   = "De".ljust(8)
    to_entete     = "à".ljust(8)
    route_entete  = "Routes".ljust(5)
    entete = "#{ip_entete} #{nb_entete} #{duree_entete} #{whois_entete} #{from_entete} #{to_entete} #{route_entete}"

    known_ips   = {}
    unknown_ips = []

    @report[:by_ip].each do |ip, ipdata|
      ip_str = ip.ljust(20)
      nb_str = ipdata[:nombre_connexions].to_s.ljust(4)
      first_str   = Time.at(ipdata[:first_connexion_time]).strftime("%H:%M:%S")
      last_str    = Time.at(ipdata[:last_connexion_time]).strftime("%H:%M:%S")
      duree       = ipdata[:last_connexion_time] - ipdata[:first_connexion_time]
      duree_str   = duree.to_s.ljust(5)
      pseudo_ipdata = pseudo_in_ipdata(ipdata)
      whois_str   = pseudo_ipdata.ljust(30)
      routes_str  = ipdata[:nombre_routes].to_s.rjust(5)

      data_line = "#{ip_str} #{nb_str} #{duree_str} #{whois_str} #{first_str} #{last_str} #{routes_str}"
      if pseudo_ipdata == '- unknown -'
        unknown_ips << data_line
      else
        known_ips.key?(pseudo_ipdata) || known_ips.merge!(pseudo_ipdata => [])
        known_ips[pseudo_ipdata] << data_line
      end
    end

    mess = "\nNombre total d'IPs : #{@report[:by_ip].count}"
    mess += "\nIPs connues : #{known_ips.count}"
    mess += "\nIPs inconnues : #{unknown_ips.count}"

    known_ips     = known_ips.collect{ |nom, arr| arr.join("\n") }.join("\n")
    unknown_ips   = unknown_ips.join("\n")

    mess += "\n=== IPs INCONNUES ===\n"
    mess += known_ips
    mess += "\n=== IPs CONNUES ===\n"
    mess += known_ips

    # On ajoute les routes empruntées par IP
    mess += "\n\n=== ROUTES PAR IPS ===\n"
    mess += @report[:by_ip].collect do |ip, ipdata|
      "#{ip} #{pseudo_in_ipdata ipdata}\n" +
      ipdata[:routes].collect do |route|
        route_linked = "<a href=\"http://www.laboiteaoutilsdelauteur.fr/#{route}\">#{route}</a>"
        "\t- #{route_linked}"
      end.join("\n")
    end.join("\n\n")

    # Constitution finale du rapport administrateur
    mess = "<pre style='font-size:9pt'>\n#{titre}\n\n#{entete}\n#{mess}\n</pre>"
    @report[:message] = mess + message_sous_rapport
    @report[:titre]   = titre

    log "RÉSULTATS À ENVOYER :\nTitre : #{@report[:titre]}\nMessage :\n#{@report[:message]}"

  end

  def pseudo_in_ipdata ipdata
    whois = ipdata[:whois]
    case whois
    when NilClass then "- unknown -"
    when String   then whois
    when Hash
      if whois.key?(:pseudo)
        whois[:short_pseudo] || whois[:pseudo]
      elsif whois.key?(:id)
        User::get(whois[:id]).pseudo
      elsif whois.key?(:user_id)
        User::get(whois[:user_id]).pseudo
      else
        "INCONNU AVEC CLÉS #{whois.keys.join(', ')}"
      end
    else
      # Ni String, ni Nil, ni Hash
      "- unknown & unfoundable (whois est #{whois.class}) -"
    end
  end

  def message_sous_rapport
    <<-HTML
<p class='small'>La durée est exprimée en secondes.</p>
<p class='small'>Ces rapports de connexions peuvent être récupérés en fichier dans le dossier `./CRON/rapports_connexions/`.</p>
    HTML
  end
  # Rationalisation des résultats
  # On passe en revue chaque IP enregistrée et
  # on marque :
  #   - son nombre de connexions
  #   - son temps de première connexion (first_connexion_time)
  #   - son temps de dernière connexion (last_connexion_time)
  def rationalise_connexions
    log "-> rationalise_connexions"
    @report[:by_ip].each do |ip, ipdata|

      times   = ipdata[:times]
      routes  = ipdata[:routes].uniq

      # Est-ce que c'est une ip connue ?
      whois = nil
      if known_ips.key?(ip)
        whois = known_ips[ip]
      else
        search_engine_ips.each do |mid, mdata|
          mdata[:ips].each do |cip|
            if cip =~ ip
              whois = mdata[:pseudo]
              break
            end
          end
          break if whois
        end
      end

      @report[:by_ip][ip].merge!(
        ip:                   ip,
        whois:                whois,
        nombre_connexions:    times.count,
        first_connexion_time: times.min,
        last_connexion_time:  times.max,
        routes:               routes, # uniques, ici
        nombre_routes:        routes.count
      )
    end
    # log "@report : #{@report.pretty_inspect}"
  end

  def known_ips
    @known_ips ||= begin
      require './data/secret/known_ips.rb'
      KNOWN_IPS
    end
  end

  def search_engine_ips
    @search_engine_ips ||= begin
      SEARCH_ENGINES_IPS_LIST
    end
  end

  # récolte les connexions par ip
  def recolte_connexions_by_ip
    # On passe en revue toutes les bases
    Dir["#{folder_connexions_report}/*.db"].each do |p|
      dbase   = SQLite3::Database::new(p)
      connexions = dbase.execute("SELECT * FROM connexions").each do |res|
        ip, time, route = res
        @report[:by_ip][ip] ||= {times: Array::new, routes: Array::new}
        @report[:by_ip][ip][:times]   << time
        @report[:by_ip][ip][:routes]  << route
      end
    end
  end

  # Envoi du rapport à l'administration
  def send_report
    log "   -> Envoi du rapport de connexion à l'administration"
    log "      Mail : #{site.mail}"
    res = site.send_mail(
      to:         site.mail,
      from:       site.mail,
      subject:    report[:titre],
      message:    report[:message],
      formated:   true
    )
    if res === true
      log "    <- OK Rapport envoyé avec succès"
    else
      mess_err = ["# ERREUR EN TRANSMETTANT LE RAPPORT :"]
      mess_err << res.message
      mess_err += res.backtrace
      mess_err = "    " + mess_err.join("\n    ")
      log mess_err
      log "    <- SiteHtml::Connexions::send_report"
    end
  end

  # On enregistre le rapport dans un fichier
  def consigne_report
    folder_rapports = "#{RACINE}/CRON/rapports_connexions"
    `mkdir -p #{folder_rapports}`
    ntime = Time.now.strftime("%d_%m_%Y-%H-%M")
    path_rapport = File.join(folder_rapports, "connexions-#{ntime}")
    File.open(path_rapport, 'wb'){ |f|
      f.puts report[:titre]
      f.puts report[:message]
    }
  end
  # Destruction des bases actuelles
  # Noter qu'elles ont été mises de côté pour ne
  # pas empêcher le fonctionnement normal pendant
  # qu'on calcule
  def reset_databases_connexions
    folder_connexions_report.remove
  end

  def folder_connexions
    @folder_connexions ||= SuperFile::new('./tmp/connexions')
  end
  def folder_connexions_report
    @folder_connexions_report ||= SuperFile::new('./tmp/connexions_report')
  end


end #/Connexions
end #/SiteHtml
