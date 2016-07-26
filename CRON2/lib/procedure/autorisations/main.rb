# encoding: UTF-8
=begin

  Pour gérer les autorisations

=end
class CRON2

  # Méthode principale appelée par le cron
  def autorisations
    Autorisations.new.check_autorisations
  end

  class Autorisations

    include MethodesProcedure

    # Réinitialisation
    #
    # Appelée en début de check, cette méthode est surtout
    # utile aux tests.
    def reset_all
      @autorisations = nil
    end

    # Vérifie les autorisations des utilisateurs.
    #
    #   1. Les autorisations arrivées à expiration sont
    #      supprimées.
    #   2. On avertit les user ayant des autorisations arrivant
    #      bientôt à expiration lorsque ce sont des abonnements
    #      et qu'il n'y a pas d'autre
    def check_autorisations

      reset_all

      # Liste des IDs d'autorisation qu'il faudra détruire
      autoids_to_destroy = Array.new

      autorisations.each do |uid, uautos|
        log "* Check autorisations de User ##{uid}"

        huser = {
          id:           uid,
          temps_debut:  nil,
          temps_fin:    nil
        }

        # Dans un premier temps, on va supprimer toutes les
        # autorisation qui sont out-of-time
        #
        good_autos = Array.new
        uautos.each do |dauto|
          if dauto[:end_time] && dauto[:end_time] < (NOW + 1.hour)
            # On mémorise que cet enregistrement doit être
            # détruit
            autoids_to_destroy << dauto[:id]
            # On prend aussi les temps pour l'user
            if huser[:temps_debut].nil?
              huser[:temps_debut] = dauto[:start_time]
            elsif dauto[:start_time] && huser[:temps_debut] > dauto[:start_time]
              huser[:temps_debut] = dauto[:start_time]
            end
            if huser[:temps_fin].nil?
               huser[:temps_fin] = dauto[:end_time]
             elsif dauto[:end_time] && huser[:temps_fin] < dauto[:end_time]
               huser[:temps_fin] = dauto[:end_time]
             end
          else
            good_autos << dauto
          end
        end

        # Inutile de poursuivre s'il n'y a plus d'autorisations
        # mais avant de passer à la suite il faut avertir l'user
        # qu'il n'a plus d'abonnement
        #
        # Noter que si l'user est traité ici, c'est parce qu'il avait
        # des autorisations, et s'il n'a plus d'autorisations ici,
        # c'est que son abonnement est terminé (tous ses enregistrements
        # s'il en a plusieurs)
        #
        if good_autos.empty?
          fin_echeance_abonnement huser
          next
        end

        # Temps de début et temps de fin restant à l'user
        temps_debut = nil
        temps_fin   = nil
        good_autos.each do |dauto|
          if temps_debut.nil? || (dauto[:start_time] && dauto[:start_time] < temps_debut)
            temps_debut = dauto[:start_time]
          end
          if temps_fin.nil? || (dauto[:end_time] && dauto[:end_time] > temps_fin)
            temps_fin = dauto[:end_time]
          end
        end
        huser.merge!(
          temps_debut:  temps_debut,
          temps_fin:    temps_fin
        )

        # Si un temps de fin est défini, on regarde s'il faut
        # avertir l'user que son abonnement (ou autre) arrive à
        # expiration.
        #
        # On ne fait le test des trois semaines avant que si c'est
        # un abonnement normal, d'un an ou un programme. Plus exactement,
        # pour table plus large, on regarde que la date de début remonte
        # à plus de 30 semaines
        #
        check_if_alerte_requise(huser) if temps_fin

      end

      unless autoids_to_destroy.empty?
        # Il faut détruire le autorisations expirées
        User.table_autorisations.delete(where: "id IN (#{autoids_to_destroy.join(', ')})")
      end

    end  #/fin de la grande méthode check_autorisations

    # Quand l'abonnement de l'user arrive à expiration,
    # on appelle cette méthode
    def fin_echeance_abonnement huser
      date_fin = huser[:temps_fin].as_human_date(true, true, ' ')
      u = User.new(huser[:id])

      # On crée un ticket pour simplifier la démarche de
      # l'user : en l'utilisant, il sera automatiquement
      # identifié et rejoindra
      ticket_code = "User.new(#{u.id}).autologin(route:'user/paiement')"
      letick = app.create_ticket(nil, ticket_code)
      lien_reabonnement = letick.link('Je veux me réabonner !')

      # Message envoyé à l'utilisateur
      message = <<-HTML
      <p>#{u.pseudo},</p>
      <p>Je dois vous informer que votre abonnement sur #{site.name}
      est arrivé à expiration.</p>
      <p>Si vous souhaitez continuer de profiter pleinement de toutes les
      ressources du site et <strong>soutenir ses efforts par votre
      participation</strong>, il vous suffit de cliquer sur le lien
      ci-dessous pour rejoindre la section de réabonnement (rappel :
      l'abonnement n'est que de #{site.tarif_humain} pour toute une année).</p>
      <p>#{lien_reabonnement}</p>
      HTML
      # Envoi du mail
      u.send_mail(
        subject: 'Expiration de votre abonnement',
        message: message.gsub(/\n/,' ').gsub(/ +/, ' ')
      )
    end

    # Quand un temps de fin est défini, mais qu'il n'est pas
    # en dépassement, on appelle cette méthode pour voir s'il
    # faut avertir l'user de la fin proche de son abonnement
    #
    def check_if_alerte_requise huser
      temps_debut = huser[:temps_debut]
      temps_fin   = huser[:temps_fin]

      dans_trois_heures     = NOW + 3.hours
      dans_trois_jours      = NOW + 3.days
      dans_une_semaine      = NOW + 1.week
      dans_trois_semaines   = NOW + 3.weeks
      trente_semaines_avant = NOW - 30.weeks

      moins_de_jours =
        case true
        when temps_fin < dans_trois_heures
          'moins de trois heures'
        when temps_fin < dans_trois_jours
          'moins de trois jours'
        when temps_fin < dans_une_semaine
          'moins d’une semaine'
        when temps_debut < trente_semaines_avant && temps_fin < dans_trois_semaines
          'moins de trois semaines'
        else
          # Dans le cas contraire on s'en retourne
          return
        end

      date_expiration = temps_fin.as_human_date(true, true, ' ', 'à')

      # Un mail doit être envoyé à l'user
      u = User.new(huser[:id])
      message = <<-HTML
      <p>#{u.pseudo},</p>
      <p>Je vous informe que votre autorisation d’accès complet à
        #{site.name} expire dans #{moins_de_jours} (le #{date_expiration}).</p>
      <p>Si vous souhaitez continuer de profiter pleinement de toutes les
      ressources du site et surtout <strong>soutenir ses efforts par votre
      participation</strong>, nous espérons que vous penserez à vous
      ré-abonner pour #{site.tarif_humain} seulement par an.</p>
      <p>D’avance un grand merci à vous !</p>
      HTML

      u.send_mail(
        subject:  'État de votre abonnement',
        message:  message.gsub(/\n/,' ').gsub(/ +/, ' ')
      )
    end

    # Renvoie toutes les autorisations courantes en les classant
    # par user.
    # CLÉ : L'ID de l'user
    # VALEUR : Liste Array des autorisations de l'auteur
    def autorisations
      @autorisations ||= begin
        h = Hash.new
        site.dbm_table(:hot, 'autorisations').select.each do |row|
          uid = row.delete(:user_id)
          h.key?(uid) || h.merge!(uid => Array.new)
          h[uid] << row
        end
        h
      end
    end

  end #/Autorisations
end
