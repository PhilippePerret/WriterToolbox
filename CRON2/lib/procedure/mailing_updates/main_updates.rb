# encoding: UTF-8
#
# Module qui permet d'envoyer les mails des dernières actualisations aux membres
# inscrits à la boite à outils
#
class CRON2
  # Méthode principale appelée par le run
  def mailing_updates
    Updates.send_mail
  rescue Exception => e
    superlog "Impossible d'envoyer les actualités : #{e.message}", {error: true}
  end

  class Updates

    include MethodesProcedure

    class << self

      def send_mail
        # Pas d'annonce si ça n'est pas l'heure (minuit)
        Time.now.hour == 0 || return

        # Pas d'annonce si la dernière annonce remonte à moins de 23 heures
        # C'est une protection dans le cas où plusieurs cron seraient appelés
        # dans l'heure, ce qui arrive souvent quand on teste.
        # L'heure est également enregistré dans la table des dernières dates
        # OBSOLÈTE puisque maintenant, puisque les actualités sont marquées
        # envoyées, on ne peut pas les envoyer deux fois.
        # site.get_last_date(:mail_updates, 0) < (Time.now - 23*3600).to_i || return

        (no_updates_no_samedi || samedi_but_no_updates ) && return

        # ----------------------------------------------
        # On procède à l'envoi des dernières actualités
        # ----------------------------------------------
        if annonce_last_updates
          # On marque que les updates ont été envoyées
          set_updates_anounced
          # On indique l'heure du dernier envoi lorsque tout s'est bien passé
          # Mais noter que cette indication n'est plus vraiment utile depuis
          # qu'on utilise deux bits d'options pour connaitre les actualités
          # à envoyer.
          site.set_last_date(:mail_updates)
          log "   = Mailing updates OK (fin de procédure)"
          superlog 'Dernières actualités envoyées'
        end

      end

      def no_updates_today
        @no_updates_today = last_updates.empty? if @no_updates_today === nil
        @no_updates_today
      end
      def no_updates_this_week
        @no_updates_this_week = last_week_updates.empty? if @no_updates_this_week === nil
        @no_updates_this_week
      end
      def no_updates_no_samedi
        @no_updates_no_samedi = no_updates_today && !samedi? if @no_updates_no_samedi === nil
        @no_updates_no_samedi
      end
      def samedi_but_no_updates
        @samedi_but_no_updates = samedi? && no_updates_this_week if @samedi_but_no_updates === nil
        @samedi_but_no_updates
      end

      def samedi?
        @is_samedi = (Time.now.wday == 6) if @is_samedi === nil
        @is_samedi
      end

      def http
        @http ||= "http://www.scenariopole.fr"
      end

      # = main =
      #
      # Méthode principale qui annonce aux inscrits et aux abonnés,
      # en fonction de leurs options, les dernières actualités.
      #
      def annonce_last_updates

        # Pour pouvoir enregistrer le dernier
        # message dans l'historique.
        message_final = nil

        # On envoie le mail à tous les destinataires en récupérant la
        # liste des users contactas (dans user_list, liste de pseudos)
        user_list = Array.new
        destinataires.each do |u_id|
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

          # ERROR : no_updates_today

          next if pref_mail == 'never'
          next if !samedi? && pref_mail == 'weekly'
          next if samedi? && pref_mail != 'weekly' && no_updates_today

          # Noter que si sa fréquence est hebdomadaire, on ne
          # passe par ici que lorsque l'on est samedi.

          # On peut transmettre le message final
          u.send_mail(
            subject:  "Dernières actualités",
            # Le message en fonction du choix de fréquence de
            # l'user.
            message:  full_message_final(u, pref_mail),
            formated: true
          )

          # pour la collecte des pseudos contactés
          user_list << u.pseudo
        end

        log "   = Mails actualité envoyés à #{user_list.count} utilisateurs : #{user_list.join(', ')}."
        log "   = Envoi des mails d'actualité OK"
        # === Enregistrement de la ligne d'historique ===
        CRON2::Histo.add( code: '31001', data: user_list.count, description: message_final )
        # ================================================
      rescue Exception => e
        log "Erreur en envoyant les mails d'actualité", e
        CRON2::Histo.add( code: '31011', description: e.message + "\n" + e.backtrace.join("\n") )
        false
      else
        true
      end
      #/annonce_last_updates

      # Le message final complet, en fonction de l'user et de ses
      # préférences mail
      def full_message_final u, pref_mail
        data_template = {
          pseudo: u.pseudo,
          id:     u.id,
          # Message d'abonnement en fin de mail
          # Si l'user est abonné, on le remercie, sinon on lui propose
          # de soutenir le site en s'abonnant.
          message_abonnement: message_souscription_by_user(u)
        }
        (pref_mail == 'weekly' ? template_week_message : template_message) % data_template
      end


      # Message de fin de mail à envoyer en fonction de la "position" de
      # l'user, s'il est abonné ou non.
      # TODO Il faudra modifier les tests ci-dessous en tenant compte du
      # fait qu'un user peut être abonné pour différentes raisons maintenant,
      # à voir dans la table des autorisations.
      def message_souscription_by_user u
        case true
        when u.admin?       then message_administrateur
        when u.subscribed?  then message_remerciement
        else message_sabonner
        end % {pseudo: u.pseudo}
      end

      # Le message template
      def template_message
        @template_message ||= begin
          <<-HTML
<p class="small">%{pseudo}, nous sommes heureux de vous faire part des dernières actualités
  de la BOITE À OUTILS DE L'AUTEUR en date du <strong>#{(Time.now.to_i - 10.hours).as_human_date(true, false, ' ')}</strong>.</p>
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
        @ul_last_updates ||= build_liste_updates( last_updates, date: false )
      end

      # Liste UL des dernières updates de LA SEMAINE
      def ul_last_week_updates
        @ul_last_week_updates ||= build_liste_updates( last_week_updates, date: true )
      end
      # Construction du UL de la liste des actualités
      #
      # Rappel : Le samedi, on utilise cette méthodep pour
      # les updates de la veille ET pour les updates de la
      # semaine.
      #
      # +options+ Les options. A été ajouté pour traiter le fait
      # que les listes hebdomadaires doivent comporter le nom du
      # jour et pas seulement l'heure. C'est l'option :
      #   :date   qui est mise à true
      #
      def build_liste_updates liste_updates, options = nil
        options ||= Hash.new

        # Le template du temps/date en fonction du fait qu'il
        # faut ou non le jour
        format_time = '%d %m - %H:%M'

        '<ul id="last_updates" class="small" style="list-style:none;margin-left:0em;">' +
        liste_updates.collect do |hupdate|
          heure = Time.at(hupdate[:created_at]).strftime(format_time)
          # degre = (hupdate[:options]||"")[0].to_i
          # degre = "#{degre}/9"
          degre = ''
          route =
            if hupdate[:route]
              r = "href='#{http}/#{hupdate[:route]}'"
              " <a #{r}>→ voir</a>"
            else
              ''
            end

          # Note : Même si c'est un inscrit on l'affiche
          mark_for_subscribers =
            if hupdate[:annonce] > 1
              "<span style='color:green'>[Abonnés]</span> "
            else
              ""
            end

          '<li style="margin-bottom: 8px">' +
            "<div class='tiny'>#{heure}</div> " +
            '<div>' +
              "<span>#{mark_for_subscribers}#{hupdate[:message]}</span>#{route}" +
            '</div>' +
            " <span class='tiny'>(catégorie : #{hupdate[:type]})</span>" +
          '</li>'
        end.join('') + '</ul>'
      end

      def message_remerciement
        <<-HTML
        <p class="small">Un grand merci à vous, %{pseudo}, pour votre soutien !</p>
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
        @last_updates ||= get_updates(for_week = false)
      end

      # Liste des dernièers actualités de la semaine précédente
      #
      # Note : On ne doit le faire que si on est samedi
      def last_week_updates
        @last_week_updates ||= begin
          if samedi?
            get_updates(for_week = true)
          else
            [] # plutôt que NIL, pour le test empty?
          end
        end
      end

      # Retourne les updates soit du jour si +for_week+ est
      # false, soit de la semaine.
      #
      # Note : c'est le 2e et 3e bit des options qui indiquent si
      # les actualités ont déjà été envoyées.
      #
      # Retourne un Hash de données d'actualités.
      #
      def get_updates for_week
        # -> MYSQL UPDATES
        where = Array.new
        # On ne fait plus de filtre par degré d'importance, mais
        # seulement si l'update doit être annoncée ou non.
        # where << "CAST(SUBSTRING(options,1,1) AS UNSIGNED) > 6"
        where << "annonce > 0"

        # Le bit 2 (quotidient) et 3 (hebdomadaire) indiquent si
        # l'actualité a été envoyée.
        if for_week
          where << "SUBSTRING(options,3,1) != '1'"
        else
          where << "SUBSTRING(options,2,1) != '1'"
        end

        # Par prudence, on n'annonce jamais les actualités
        # de plus de trois jours
        three_days_ago = NOW - 3.days

        where << "created_at > #{three_days_ago}"

        where = where.join(' AND ')
        table_updates.select(where: where, order: 'created_at ASC, type')
      rescue Exception => e
        error_log e
        Array.new
      end
      # /get_updates

      # = main =
      #
      # Méthode général appelée après l'envoi des dernières
      # actualités, qui change les bit des updates pour indiquer
      # qu'elles ont bien été envoyées aujourd'hui.
      #
      # Fonctionne aussi bien ppour les annonces quotidiennes que
      # pour les annonces hebdomadaire (2e bit d'options)
      #
      def set_updates_anounced
        nombre_marqued = 0
        # On utilise les variables elles-même (avec les @) plutôt que
        # les méthodes. De cette façon, on ne traite que ce qui a réellement
        # été traité/renseigné avant
        (@last_updates || []).each do |dactu|
          table_updates.update(dactu[:id], {
            options: dactu[:options].set_bit(1, 1),
            updated_at: Time.now.to_i
            })
          nombre_marqued += 1
        end

        (@last_week_updates || []).each do |dactu|
          table_updates.update(dactu[:id], {
            options: dactu[:options].set_bit(2, 1),
            updated_at: Time.now.to_i
            })
          nombre_marqued += 1
        end

        log "   = Updates marquées annoncées (#{nombre_marqued})"
      rescue Exception => e
        log "  # Les updates n'ont pas pu être marquées annoncées : #{e.message}"
      end

      # La table contenant toutes les updates
      def table_updates
        @table_updates ||= site.dbm_table(:cold, 'updates')
      end

      # Liste des destinataires des mails.
      # Ce sont les membres inscrits et abonnés qui acceptent
      # de recevoir cette information.
      # C'est une liste `Array` d'éléments : [mail, pseudo]
      def destinataires
        @destinataires ||= begin
          # Il faut que l'user soit inscrit ou abonné, et que ses
          # options précisent qu'il veut recevoir les mails d'actualité
          # Il ne doit pas être détruit
          where = 'options NOT LIKE "___1%"'
          User.table_users.select(where: where, colonnes:[]).collect{|huser| huser[:id]}
        rescue Exception => e
          error_log e
          []
        end
      end

    end # <<self
  end #/CRON2::Updates
end #/CRON2
