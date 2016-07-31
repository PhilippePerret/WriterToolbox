# encoding: UTF-8
=begin

Module de construction du bloc des "hot news" en bas
de la page d'accueil du site.

Ce module n'est chargé que s'il faut actualisé ce bloc, après
un changement dans les informations.

=end
class SiteHtml

  # Section des dernières actualités, en bas de la page
  # d'accueil.
  def section_hot_news
    (

      bloc_actualite_if_any(:narration)  +
      bloc_actualite_if_any(:analyses)   +
      bloc_actualite_if_any(:videos) +
      bloc_actualite_if_any(:unan_unscript)+
      bloc_actualite_if_any(:forum) +
      bloc_actualite_if_any(:divers)
    ).in_section(id:'hot_news')
  end

  # ---------------------------------------------------------------------
  #   Bloc des actualités
  # ---------------------------------------------------------------------

  def bloc_actualite_if_any actu_id
    send("bloc_actualite_#{actu_id}".to_sym).in_div(class:'blocactu')
  end

  # ---------------------------------------------------------------------
  #     NARRATION
  # ---------------------------------------------------------------------
  def bloc_actualite_narration
    titre_bloc_actu("Col. Narration", "cnarration/home") +
    "Derniers cours :".in_span(class:'label') +
    narration_liste_three_last_pages
  end
  def narration_liste_three_last_pages
    require './objet/cnarration/lib/required/constants.rb'
    narration_dernieres_pages_cours.collect do |dpage|
      page_id = dpage[:id]
      titre_page = dpage[:titre]
      livre_id = dpage[:livre_id]
      niveau_dev = dpage[:options][1].to_i
      created_at = dpage[:created_at]
      updated_at = dpage[:updated_at]
      livre_id = livre_id.to_i
      livre = begin
        titre_livre = Cnarration::LIVRES[livre_id][:short_hname]
        titre_livre = titre_livre.in_a(href:"livre/#{livre_id}/tdm?in=cnarration", target:"_blank")
        " (#{titre_livre})".in_span(class:'tiny')
      end
      # Si la page a été créée il y a longtemp, elle est marquée comme
      # une simple modification, sinon c'est une création.
      # La page est considérée comme une création lorsqu'elle a été
      # créée dans le mois de sa dernière modification
      simple_modification = updated_at - created_at < 31.days
      est = (simple_modification ? "" : "(création) ".in_span(class:'tiny'))

      title = "Cliquez ici pour lire la page de cours “#{titre_page}” achevée le #{updated_at.as_human_date(true, false, ' ')}".strip_tags
      titre_page = "#{DOIGT}#{est}“#{titre_page}”".in_a(href:"page/#{page_id}/show?in=cnarration", target:"_blank", title:title)
      "#{titre_page}#{livre}".in_div(class:'actu')
    end.join('')
  end

  # On prend les
  def narration_dernieres_pages_cours
    site.dbm_table(:cnarration, 'narration').select(
      where: "CAST(SUBSTRING(options,2,1) as UNSIGNED) >= 8",
      order: 'updated_at DESC',
      limit: 3,
      colonnes: [:titre, :livre_id, :options, :created_at, :updated_at]
    )
  end

  # ---------------------------------------------------------------------
  #     ANALYSES DE FILMS
  # ---------------------------------------------------------------------
  def bloc_actualite_analyses
    titre_bloc_actu("Analyses de film", 'analyse/home') +
    "Derniers films analysés :".in_span(class:'label') +
    dernieres_analyses_films
  end

  def dernieres_analyses_films
    drequest = {
      where:    "SUBSTRING(options, 5, 1) = '1'",
      order:    'updated_at DESC',
      limit:    3,
      colonnes: [:film_id, :titre, :updated_at]
    }
    site.dbm_table(:biblio, 'films_analyses').select(drequest).collect do |dana|
      fid         = dana[:id]
      film_id     = dana[:film_id]
      titre       = dana[:titre].force_encoding('utf-8')
      updated_at  = dana[:updated_at]
      title = "Cliquez ici pour consulter l'analyse du film “#{titre}” produite le #{updated_at.as_human_date(true,false,' ')}"
      titre_film = "#{DOIGT}#{titre}".in_a(href:"analyse/#{fid}/show", target:"_blank", title:title.strip_tags)
      "#{titre_film}".in_div(class:'actu')
    end.join('')
  end

  # ---------------------------------------------------------------------
  #   PROGRAMME UN AN
  # ---------------------------------------------------------------------
  def bloc_actualite_unan_unscript
    titre_bloc_actu("#{Unan::PROGNAME_MINI_MAJ}", 'unan/home') +
    "Actualités du programme :<br>".in_span(class:'label') +
    derniere_nouvelles_unan
  end

  # Dernières nouvelles du programme UN AN
  # On pioche trois actualités parmi les inscriptions ou les
  # activités générales.
  def derniere_nouvelles_unan
    d = Hash.new
    # Les dernières inscriptions (if any)
    d.merge! unan_dernieres_inscriptions
    # Les dernières activités sur le programme
    d.merge! unan_dernieres_activites

    # On prend les trois dernières et on les retourne
    # pour les mettre dans la fenêtre
    d.sort_by{ |k, v| k }[0..2].collect{ |k, actu| actu }.join('')

  end
  def unan_dernieres_inscriptions
    request_data = {
      order: 'created_at DESC',
      limit: 3,
      colonnes: [:id, :auteur_id, :projet_id, :updated_at, :created_at]
    }
    data = Hash.new
    site.dbm_table(:unan, 'programs').select(request_data).each do |hdata|
      uid = hdata[:auteur_id]
      pid = hdata[:projet_id]
      created_at = hdata[:created_at]
      upseudo = User.get(uid).pseudo
      # TODO: Pour le moment, on n'indique pas la date
      # "#{DOIGT}Inscription #{upseudo} #{as_small_date created_at}"
      data.merge! created_at => "#{DOIGT}Inscription de #{upseudo}".in_div(class:'actu')
    end
    return data
  end
  def unan_dernieres_activites
    request_data = {
      order: 'updated_at DESC',
      limit: 3,
      colonnes: [:id, :auteur_id, :projet_id, :updated_at]
    }
    data = Hash.new
    site.dbm_table(:unan, 'programs').select(request_data).each do |hdata|
      uid         = hdata[:auteur_id]
      pid         = hdata[:projet_id]
      updated_at  = hdata[:updated_at]
      upseudo = User.get(uid).pseudo
      # TODO: Pour le moment on n'indique pas la date, on le
      # fera lorsqu'il y aura pas mal d'auteurs en travail
      data.merge! updated_at => "#{DOIGT}Projet de #{upseudo} #{as_small_date updated_at}".in_div(class:'actu')
    end
    return data
  end

  # ---------------------------------------------------------------------
  #     TUTORIELS VIDÉOS
  # ---------------------------------------------------------------------
  def bloc_actualite_videos
    titre_bloc_actu("Didactitiels-vidéo", "video/home") +
    "Dernières vidéos :".in_span(class:'label') +
    derniers_tutoriels_videos
  end

  def derniers_tutoriels_videos
    require './objet/video/DATA_VIDEOS.rb'
    Video::DATA_VIDEOS.sort_by{|vid, vdata| vdata[:created_at]}[0..2].collect do |vid, vdata|
      title = "Visualiser le tutoriel vidéo  “#{vdata[:titre]}” conçu le #{vdata[:created_at].as_human_date(true, false, ' ')}."
      "#{DOIGT}#{vdata[:titre]}".in_a(href:"video/#{vid}/show", target:"_blank", title:title.strip_tags).in_div(class:'actu')
    end.join('')
  end

  # ---------------------------------------------------------------------
  #     FORUM
  # ---------------------------------------------------------------------
  def bloc_actualite_forum
    titre_bloc_actu("Forum", "forum/home") +
    "Derniers messages :".in_span(class:'label') +
    derniers_messages_forum
  end

  def derniers_messages_forum
    @derniers_messages_forum ||= begin
      table_contents = site.dbm_table(:forum, 'posts_content')
      last_messages_forum.collect do |dpost|
        pid       = dpost[:id]
        puser     = User::get(dpost[:user_id])
        pcreated  = dpost[:created_at]
        pcontent = table_contents.get(pid, colonnes:[:content])[:content]

        pseudo    = puser.pseudo
        puser     = " (#{pseudo})".in_span(class:'tiny')
        plongcontent = pcontent[0..200]
        plongcontent += " […]" if pcontent.length > 200
        pcontent  = pcontent[0..30] + " […]"
        plink     = "post/#{pid}/read?in=forum"
        title     = "Cliquer ici pour lire le dernier message de #{pseudo}, datant du #{pcreated.as_human_date(true, true, ' ')} : #{plongcontent.purified.gsub(/\n/,' ')}"
        "#{DOIGT}“#{pcontent}”#{puser}".in_a(href: plink, target:"_blank", title: title.strip_tags).in_div(class:'actu')
      end.join('')
    end
  end
  def last_messages_forum
    drequest = {
      where: "SUBSTRING(options,1,1) = '1'",
      order:  'created_at',
      limit:  3,
      colonnes: [:user_id, :created_at]
    }
    site.dbm_table(:forum, 'posts').select(drequest)
  end

  # ---------------------------------------------------------------------
  #     DIVERS ACTUALITÉS
  # ---------------------------------------------------------------------

  # Les dernières actualités diverses sont consignées
  # dans le fichier : ./hot/last_actualites.rb
  def bloc_actualite_divers
    titre_bloc_actu("Divers") +
    "Dernières actualités :".in_span(class:'label') +
    dernieres_actualites_divers +
    "[les voir toutes]".in_a(href:'site/updates', class:'tiny').in_div(class:'right')
  end
  def dernieres_actualites_divers
    require './hot/last_actualites'
    dernieres_actualites_generales.collect do |arrdata|
      message, hdate = arrdata
      t =
        case hdate
        when String
          djour, dmois, dannee = hdate.split(/[ \/]/)
          Time.new(dannee.to_i, dmois.to_i, djour.to_i).to_i
        when Fixnum
          hdate
        end
      "#{DOIGT}#{message}#{as_small_date t}".in_div(class:'actu')
    end.join('')
  end


  # ---------------------------------------------------------------------
  #     HELPER METHODES
  # ---------------------------------------------------------------------

  # Un titre de bloc d'actualité (avec "News" écrit flottant à droite)
  def titre_bloc_actu titre, url = nil
    titre = titre.upcase
    titre = titre.in_a( href: url ) unless url.nil?
    (
      "#{PUNAISE_ROUGE}".in_span(class:'relative') +
      "#{titre}"
    ).in_div(class:'title')
  end

  # On envoie le timestamp et la méthode retourne le span
  # avec la date entre parenthèse en tiny
  def as_small_date ti = NOW
    " (#{ti.as_human_date})".in_span(class:'tiny')
  end

end #/SiteHtml
