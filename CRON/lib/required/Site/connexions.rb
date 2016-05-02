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
    ireport.send_report
    ireport.reset_databases_connexions
    log "  = Résumé des connexions OK"
    log "<- SiteHtml::Connexions::resume"
  rescue Exception => e
    log "# ERREUR AU COURS DU RAPPORT DE CONNEXIONS : #{e.message}"
    log e.backtrace.join("\n")
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
    freq = code.scan(/^site\.alert_apres_login ?= ?(.*?)$/).to_a[0][0]
    case freq
    when nil
    when ":tout_de_suite", ":now"
      false # c'est géré autrement
    when ":one_a_day", "une_page_jour"
      # Retourne true si on est dans la première heure du jour
      return premiere_heure
    when "one_a_week", ":une_par_semaine"
      return now.wday == 1 && premiere_heure
    when "one_a_month", ":une_par_mois"
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

  # On construit le message pour l'administrateur
  def build_message_admin
    titre = "Rapport des connexions du #{Time.now}"

    ip_entete     = "IP".ljust(20)
    nb_entete     = "Nb".ljust(4)
    duree_entete  = "Durée".ljust(5)
    whois_entete  = "Whois".ljust(30)
    from_entete   = "De".ljust(8)
    to_entete     = "à".ljust(8)
    route_entete  = "Routes".ljust(5)
    entete = "#{ip_entete} #{nb_entete} #{duree_entete} #{whois_entete} #{from_entete} #{to_entete} #{route_entete}"

    mess = @report[:by_ip].collect do |ip, ipdata|
      ip_str = ip.ljust(20)
      nb_str = ipdata[:nombre_connexions].to_s.ljust(4)
      first_str = Time.at(ipdata[:first_connexion_time]).strftime("%H:%M:%S")
      last_str  = Time.at(ipdata[:last_connexion_time]).strftime("%H:%M:%S")
      duree  = ipdata[:last_connexion_time] - ipdata[:first_connexion_time]
      duree_str = duree.to_s.ljust(5)
      whois_str = (ipdata[:whois].nil? ? "- unknown -" : ipdata[:whois] ).ljust(30)
      routes_str = ipdata[:nombre_routes].to_s.rjust(5)
      "#{ip_str} #{nb_str} #{duree_str} #{whois_str} #{first_str} #{last_str} #{routes_str}"
    end.join("\n")

    # On ajoute les routes empruntées par IP
    mess += "\n\n=== ROUTES PAR IPS ===\n"
    mess += @report[:by_ip].collect do |ip, ipdata|
      "#{ip}\n" +
      ipdata[:routes].collect do |route|
        "\t- #{route}"
      end.join("\n")
    end.join("\n\n")

    # Constitution finale du rapport administrateur
    mess = "<pre>\n#{titre}\n\n#{entete}\n#{mess}\n</pre>"
    @report[:message] = mess + message_sous_rapport
    @report[:titre]   = titre
  end

  def message_sous_rapport
    <<-HTML
<p>La durée est exprimée en secondes.
</p>
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
      if known_ips.has_key?(ip)
        whois = known_ips[ip]
      else
        search_engine_ips.each do |mid, mdata|
          if mdata[:ip] =~ ip
            whois = mdata[:pseudo]
          end
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
    site.send_mail(
      to:         site.mail,
      from:       site.mail,
      subject:    report[:titre],
      message:    report[:message],
      formated:   true
    )
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
