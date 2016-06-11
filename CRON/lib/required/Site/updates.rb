# encoding: UTF-8
=begin

  Module gérant l'envoi des actualisations aux membres
  inscrits et abonnés.

=end

class SiteHtml
class Updates
class << self

  def http
    @http ||= "http://www.laboiteaoutilsdelauteur.fr"
  end

  def samedi?
    @is_samedi = (Time.now.wday == 6) if @is_samedi === nil
    @is_samedi
  end

  # = main =
  #
  # Méthode principale qui annonce aux inscrits et aux abonnés,
  # en fonction de leurs options, les dernières actualités.
  #
  def annonce_last_updates
    safed_log "  -> Annonce last updates"

    # Pas d'annonce si ça n'est pas l'heure
    if Time.now.hour != 0
      safed_log '   = Pas l’heure d’envoyer les mails d’actualité' +
                '   <- (annonces last updates)'
      return
    end

    # Pas d'annonce s'il n'y a aucune actualité
    no_updates_today = last_updates.empty?
    no_updates_this_week = last_week_updates.empty?

    if (no_updates_today && !samedi?) || (samedi? && no_updates_this_week)
      safed_log "   = Aucune actualité"
      return
    end

    # On envoie le mail à tous les destinataires
    #
    user_list =
      destinataires.collect do |u_id|

        u = User.new(u_id)

        pref_mail = u.preference(:mail_updates)

        # On ne doit pas envoyer le mail à l'user :
        #  - s'il a réglé ses préférences sur 'never'
        #  - s'il a réglé ses préférences sur 'weekly' et
        #    qu'on n'est pas samedi.
        #  - S'il veut recevoir les actualités mais qu'il n'y
        #    en a pas mais qu'on est samedi avec des actualités
        #    dans la semaine
        # Noter bien qu'on passe ici le samedi, même s'il n'y a
        # aucune update aujourd'hui, mais qu'il y en a eu pendant
        # la semaine
        next if pref_mail == 'never'
        next if !samedi? && pref_mail == 'weekly'
        next if samedi? && pref_mail != 'weekly' && no_updates_today

        # Message d'abonnement en fin de mail
        # Si l'user est abonné, on le remercie, sinon on lui propose
        # de soutenir le site en s'abonnant.
        mess_subscribe =
          case true
          when u.admin?         then (message_administrateur % {pseudo: u.pseudo})
          when u.subscribed?    then message_remerciement
          else message_sabonner
          end

        # Le message en fonction du choix de fréquence de
        # l'user.
        # Noter que si sa fréquence est hebdomadaire, on ne
        # passe par ici que lorsque l'on est samedi.
        message_final =
          if pref_mail == 'weekly'
            template_week_message
          else
            template_message
          end % {pseudo: u.pseudo, id: u.id, message_abonnement: mess_subscribe}

        # On peut transmettre le message final
        u.send_mail(
          subject:  "Dernières actualités",
          message:  message_final,
          formated: true
        )

        u.pseudo # pour la collecte
      end.compact

    safed_log "   = Mails actualité envoyés à #{user_list.count} utilisateurs : #{user_list.join(', ')}."
    safed_log "   = Envoi des mails d'actualité OK"
    return true
  rescue Exception => e
    error_log e
    false
  end

  # Le message template
  def template_message
    @template_message ||= begin
      <<-HTML
  <p class="small">%{pseudo}, nous sommes heureux de vous faire part des dernières actualités
    de la BOITE À OUTILS DE L'AUTEUR.</p>
  #{ul_last_updates}
  <p class="tiny">Notez que nous ne sommes nullement là pour vous
    importuner, aussi,
    <strong>si vous ne désirez plus recevoir ces messages</strong>, il vous
    suffit de l'indiquer dans les #{lien_preferences}.</p>
  %{message_abonnement}
  <p class="small">Merci de votre attention, %{pseudo}, et profitez bien de la BOITE À OUTILS DE L'AUTEUR !</p>
      HTML
    end
  end
  # Le message template pour la semaine
  def template_week_message
    @template_week_message ||= begin
      <<-HTML
  <p class="small">%{pseudo}, nous sommes heureux de vous faire part des dernières actualités
    de la BOITE À OUTILS DE L'AUTEUR pour la semaine écoulée.</p>
  #{ul_last_week_updates}
  <p class="tiny">Notez que nous ne sommes nullement là pour vous
    importuner, aussi,
    <strong>si vous ne désirez plus recevoir ces messages</strong>, il vous
    suffit de l'indiquer dans les #{lien_preferences}.</p>
  %{message_abonnement}
  <p class="small">Merci de votre attention, %{pseudo}, et profitez bien de la BOITE À OUTILS DE L'AUTEUR !</p>
      HTML
    end
  end

  def lien_preferences
    @lien_preferences ||= "<a href='#{http}/user/%{id}/profil'>préférences de votre profil</a>"
  end

  # Liste UL des dernières updates de la veille
  def ul_last_updates
    @ul_last_updates ||= build_liste_updates( last_updates )
  end

  # Liste UL des dernières updates de LA SEMAINE
  def ul_last_week_updates
    @ul_last_week_updates ||= build_liste_updates( last_week_updates )
  end
  # Construction du UL de la liste des actualités
  #
  # Rappel : Le samedi, on utilise cette méthodep pour
  # les updates de la veille ET pour les updates de la
  # semaine.
  #
  def build_liste_updates liste_updates
    '<ul id="last_updates" class="small">' +
    liste_updates.collect do |hupdate|
      heure = Time.at(hupdate[:created_at]).strftime("%H:%M")
      degre = (hupdate[:options]||"")[0].to_i
      degre = "#{degre}/9"
      route =
        if hupdate[:route]
          r = "href='#{http}/#{hupdate[:route]}'"
          " <a #{r}>-&gt; voir</a>"
        else
          ""
        end

      # Note : Même si c'est un inscrit on l'affiche
      mark_for_subscribers =
        if hupdate[:annonce] > 1
          "<span style='color:green'>[Abonnés]</span> "
        else
          ""
        end

      '<li>'+
        "<span>#{heure}</span> : " +
        "<span>#{mark_for_subscribers}#{hupdate[:message]}</span>#{route}" +
        " <span class='tiny'>(catégorie : #{hupdate[:type]} — importance : #{degre})</span>" +
      '</li>'
    end.join('') + '</ul>'
  end

  def message_remerciement
    <<-HTML
<p class="small">Un grand merci à vous de soutenir le site par votre abonnement !</p>
    HTML
  end
  def message_sabonner
    vous_abonnant = "<a href='#{http}/user/paiement'>la soutenir en vous abonnant</a>"
    <<-HTML
<p class="small">
  Si LA BOITE vous apporte une quelconque aide,
  que penseriez-vous de #{vous_abonnant} ? (vraiment, c'est
  une petite dépense pour vous mais c'est d'un immense apport pour la
  boite qui vous remercie par avance).
</p>
    HTML
  end
  def message_administrateur
    <<-HTML
<p class="tiny">%{pseudo}, vous recevez ce message parce que vous
  administrez la Boite à outils de l'auteur.
</p>
    HTML
  end



  # Liste des dernières actualisations
  def last_updates
    @last_updates ||= begin
      require 'sqlite3'
      now   = Time.now
      hier  = now - (3600*24)
      hier_matin  = Time.new(hier.year, hier.month, hier.day, 0, 0, 0).to_i
      ce_matin    = Time.new(now.year, now.month, now.day, 0, 0, 0).to_i
      get_updates(from = hier_matin, to = ce_matin)
    end
  end

  # Liste des dernièers actualités de la semaine précédente
  #
  # Note : On ne doit le faire que si on est samedi
  def last_week_updates
    @last_week_updates ||= begin
      if samedi?
        now  = Time.now
        awa  = now - (7*3600*24) # a week ago
        awa_matin = Time.new(awa.year, awa.month, awa.day, 0, 0, 0).to_i
        now_matin = Time.new(now.year, now.month, now.day, 0, 0, 0).to_i
        get_updates(from = awa_matin, to = now_matin)
      else
        [] # plutôt que NIL pour le test empty?
      end
    end
  end

  # Retourne les updates de +from+ (compris) à +to+ (non compris)
  def get_updates from, to
    where = []
    # On ne fait plus de filtre par degré d'importance, mais
    # seulement si l'update doit être annoncée ou non.
    # where << "CAST(SUBSTR(options,1,1) AS INTEGER) > 6"
    where << "created_at >= #{from} AND created_at < #{to}"
    where << "annonce > 0"
    where = where.join(' AND ')
    req = "SELECT message, route, type, created_at, options, annonce FROM updates WHERE #{where} ORDER BY created_at ASC, type"
    db = SQLite3::Database.new('./database/data/site_cold.db')
    pr = db.prepare req
    res = []
    pr.execute.each_hash do |h|
      res << {message: h['message'], type: h['type'], annonce: h['annonce'].to_i, created_at: h['created_at'], route: h['route'], options: h['options']}
    end
  rescue Exception => e
    error_log e
    []
  else
    res
  ensure
    (db.close if db) rescue nil
    (pr.close if pr) rescue nil
  end

  # Liste des destinataires des mails.
  # Ce sont les membres inscrits et abonnés qui acceptent
  # de recevoir cette information.
  # C'est une liste `Array` d'éléments : [mail, pseudo]
  def destinataires
    @destinataires ||= begin
      require 'sqlite3'
      require './data/secret/data_phil'
      arr = []
      # WHERE CLAUSE
      # Il faut que l'user soit inscrit ou abonné, et que ses
      # options précisent qu'il veut recevoir les mails d'actualité
      # Il ne doit pas être détruit
      where = 'options NOT LIKE "___1%"'
      req = "SELECT id FROM users WHERE #{where}"
      db = SQLite3::Database.new('./database/data/users.db')
      pr = db.prepare req
      pr.execute.each_hash do |huser|
        arr << huser['id']
      end
    rescue Exception => e
      error_log e
      arr
    else
      arr
    ensure
      (pr.close if pr) rescue nil
      (db.close if db) rescue nil
    end
  end
end #/<< self
end #/Updates
end #/SiteHtml
