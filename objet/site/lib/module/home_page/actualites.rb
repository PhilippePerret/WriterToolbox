# encoding: UTF-8
=begin

Module de construction du bloc des "hot news" en bas
de la page d'accueil du site.

Ce module n'est chargé que s'il faut actualisé ce bloc, après
un changement dans les informations.

=end
class SiteHtml

  # Voir le fichier ./hot/spotlight.rb qui définit SPOTLIGHT
  def section_spotlight
    require './hot/spotlight'
    lien_spotlight = SPOTLIGHT[:title].in_a(href:SPOTLIGHT[:href])
    (
      "#{FLASH} #{FLASH} #{FLASH} &nbsp;COUP DE PROJECTEUR&nbsp; #{FLASH} #{FLASH} #{FLASH}".in_div(class:'bold tiny') +
      "#{DOIGT_WHITE}#{SPOTLIGHT[:before]}#{lien_spotlight}#{SPOTLIGHT[:after]} ".in_div
    ).in_section(id:'home_spotlight', onclick:"document.location.href='#{SPOTLIGHT[:href]}'")
  end

  # Section des dernières actualités, en bas de la page
  # d'accueil.
  def section_hot_news
    (

      bloc_actualite_if_any(:narration)  +
      bloc_actualite_if_any(:analyses)   +
      bloc_actualite_if_any(:unan_unscript) +
      bloc_actualite_if_any(:videos) +
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
    narration_dernieres_pages_cours.collect do |arr_dpage|
      page_id, titre_page, livre_id, niveau_dev, created_at, updated_at = arr_dpage
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
    request = <<-SQL
SELECT id, titre, livre_id, CAST( SUBSTR(options,2,1) as INTEGER ) as nivdev, created_at, updated_at
  FROM pages
  WHERE nivdev > 6
  ORDER BY updated_at DESC
  LIMIT 3
    SQL
    p = './database/data/cnarration.db'
    SQLite3::Database::new(p).execute(request)
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
    p = './database/data/analyse.db'
    request = request_analyses_film.gsub(/\t/,' ').gsub(/\n/,' ')
    SQLite3::Database::new(p).execute(request).collect do |dana|
      fid, film_id, titre, updated_at = dana
      title = "Cliquez ici pour consulter l'analyse du film “#{titre}” produite et achevée par #{analystes_of fid} le #{updated_at.as_human_date(true,false,' ')}"
      titre_film = "#{DOIGT}#{titre}".in_a(href:"analyse/#{fid}/show", target:"_blank", title:title.strip_tags)
      "#{titre_film}".in_div(class:'actu')
    end.join('')
  end

  # Retourne la liste des analyses du film d'identifiant +fid+
  # TODO: Implémenter la vraie procédure une fois que la table
  # analyse.travaux sera mise en place et fonctionnelle.
  def analystes_of fid
    return "Phil"
    @db_travaux ||= SQLite3::Database::new('./database/data/analyse.db')
    request = <<-SQL
SELECT user_id
  FROM travaux
  INNER JOIN films
  ON travaux.film_id = films.id
  WHERE films.id = #{fid}
    SQL
    @db_travaux.execute(request).collect do |fdata|
      User::get(fdata[:user_id] || 1).pseudo
    end.pretty_join
  end

  # Requête pour relever les dernières analyses de film
  # On prend seulement les 3 dernières lisibles en les classant
  # par dernière modification
  def request_analyses_film
    <<-SQL
SELECT id, film_id, titre, updated_at
  FROM  films
  WHERE SUBSTR(options, 5, 1) = '1'
  ORDER BY updated_at DESC
  LIMIT 3
    SQL
  end

  # ---------------------------------------------------------------------
  #   PROGRAMME UN AN UN SCRIPT
  # ---------------------------------------------------------------------
  def bloc_actualite_unan_unscript
    titre_bloc_actu("UN AN UN SCRIPT", 'unan/home') +
    "Actualités du programme :<br>".in_span(class:'label') +
    derniere_nouvelles_unan
  end

  def derniere_nouvelles_unan
    @db_programs_unan = SQLite3::Database::new('./database/data/unan_hot.db')
    # Les dernières inscriptions (if any)
    unan_dernieres_inscriptions +
    # Les dernières activités sur le programme
    unan_dernieres_activites
    # Des actualités "forcées"
  end
  def unan_dernieres_inscriptions
    @db_programs_unan.execute(request_derniers_programmes_unan).collect do |arrdata|
      uid, pid, created_at = arrdata
      upseudo = User::get(uid).pseudo
      # TODO: Pour le moment, on n'indique pas la date
      # "#{DOIGT}Inscription #{upseudo} #{as_small_date created_at}"
      "#{DOIGT}Inscription #{upseudo}".in_div(class:'actu')
    end.join('')
  end
  def unan_dernieres_activites
    @db_programs_unan.execute(request_dernieres_activites_unan).collect do |arrdata|
      pid, puser, pprojet, pupdate = arrdata
      puser = User::get(puser).pseudo
      # TODO: Pour le moment on n'indique pas la date, on le
      # fera lorsqu'il y aura pas mal d'auteurs en travail
      # "#{DOIGT}Projet de #{puser} #{as_small_date pupdate}"
      "#{DOIGT}Projet de #{puser}".in_div(class:'actu')
    end.join('')
  end
  # Requête SQL pour récupérer les dernières activités dans
  # les programmes UN AN UN SCRIPT.
  # Pour ça, on relève simplement les derniers programmes
  # modifiés.
  def request_dernieres_activites_unan
    req = <<-SQL
SELECT
  id, auteur_id, projet_id, updated_at
  FROM programs
  ORDER BY updated_at DESC
  LIMIT 3
    SQL
    req.gsub(/\t/, ' ').gsub(/\n/, ' ')
  end
  def request_derniers_programmes_unan
    req = <<-SQL
SELECT
  auteur_id, projet_id, created_at
  FROM programs
  ORDER BY created_at DESC
  LIMIT 2
    SQL
    req.gsub(/\t/,' ').gsub(/\n/,' ')
  end

  def request

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
      db = SQLite3::Database::new('./database/data/forum.db')
      db.execute(request_forum.gsub(/\n/,'')).collect do |dpost|
        pid, puser, pcontent, dcreated = dpost
        puser     = User::get(puser)
        pseudo    = puser.pseudo
        puser     = " (#{pseudo})".in_span(class:'tiny')
        plongcontent = pcontent[0..200]
        plongcontent += " […]" if pcontent.length > 200
        pcontent  = pcontent[0..30] + " […]"
        plink     = "post/#{pid}/read?in=forum"
        title     = "Cliquer ici pour lire le dernier message de #{pseudo}, datant du #{dcreated.as_human_date(true, true, ' ')} : #{plongcontent.purified.gsub(/\n/,' ')}"
        "#{DOIGT}“#{pcontent}”#{puser}".in_a(href: plink, target:"_blank", title: title.strip_tags).in_div(class:'actu')
      end.join('')
    end
  end
  def request_forum
    <<-SQL
SELECT
  posts.id, posts.user_id, posts_content.content, posts.created_at
  FROM posts
  INNER JOIN posts_content
  WHERE SUBSTR(posts.options,1,1) = '1'
  ORDER BY posts.updated_at DESC
  LIMIT 3;
    SQL
  end

  # ---------------------------------------------------------------------
  #     DIVERS ACTUALITÉS
  # ---------------------------------------------------------------------

  # Les dernières actualités diverses sont consignées
  # dans le fichier : ./hot/last_actualites.rb
  def bloc_actualite_divers
    titre_bloc_actu("Divers") +
    "Dernières actualités :".in_span(class:'label') +
    dernieres_actualites_divers
  end
  def dernieres_actualites_divers
    require './hot/last_actualites'
    dernieres_actualites_generales.collect do |arrdata|
      message, hdate = arrdata
      djour, dmois, dannee = hdate.split(/[ \/]/)
      t = Time.new(dannee.to_i, dmois.to_i, djour.to_i).to_i
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
