  # On construit le message pour l'administrateur, qui va lui
  # rapporter toutes les connexions qui ont eu lieu.

  def recolte_connexions_by_ip
    # On récupère toutes les connexions qui ont eu lieu depuis
    # le dernier rapport.
    all_connexions = table_connexions_per_ip.select
    # On définit le temps de départ à maintenant pour supprimer
    # toutes ces connexions en fin de rapport, si tout s'est
    # bien passé
    @start_time = Time.now.to_i
    all_connexions.each do |con|
      ip = con[:ip]
      @report[:by_ip][ip] ||= {times: Array::new, routes: Array::new}
      @report[:by_ip][ip][:times]   << con[:time]
      @report[:by_ip][ip][:routes]  << con[:route]
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
  def remove_connexions
    table_connexions_per_ip.delete(where: "time <= #{@start_time}")
  end

  def table_connexions_per_ip
    @table_connexions_per_ip ||= site.dbm_table(:hot, 'connexions_per_ip')
  end
end #/Connexions
end #/SiteHtml
