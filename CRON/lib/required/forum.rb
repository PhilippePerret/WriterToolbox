# encoding: UTF-8
=begin

Méthodes utiles pour le forum pour tenir informé des nouveaux
messages

Rappel : On doit regarder les nouveaux messages déposés (table_posts)
dans l'heure précédente et alerter les suiveurs des sujets concernés.
Sauf si ces suiveurs n'ont pas visité le sujet depuis la dernière
alerte.

Rappel : la table sujets_followers contient en même temps la liste
des suiveurs d'un sujet et les derniers appels.

  Nouveau message (date > now moins une heure)
  => On récupère les abonnements du sujet concerné (sujet_id)
      C'est une liste d'IDs de users (liste de user_id)
  => On teste si la donnée sujet_id + user_id existe dans la table
  Si c'est le cas, ça signifie que l'user n'a pas visité le sujet
  depuis la dernière alerte qui lui a été envoyée pour le dernier
  message
=end
class Forum
class << self


  # = main =
  #
  # Méthode principale de check des nouveaux messages éventuels déposés
  # sur le forum. Il faut prévenir tous les suiveurs qui doivent l'être (ne
  # doivent pas l'être ceux qui ont été prévenus d'une précédente réponse
  # et ne sont pas venus sur le sujet depuis).
  # @usage : Forum::check_new_messages
  def check_new_messages

    log "=== Check des nouveaux messages du forum ==="

    # Chargement de toutes les librairies du forum
    site.require_objet 'forum'

    # -> MYSQL FORUM
    # On récupère tous les messages qui ont été créés depuis le
    # dernier checkup du forum et qui sont validés.
    drequest = { where: "created_at > #{last_time_checkup} AND options LIKE '1%'"}
    drequest.merge!( colonnes: [:sujet_id] )
    new_messages = table_posts.select( drequest )

    log "= Nouveaux messages trouvés : #{new_messages.count}"

    # On actualise tout de suite la date de dernier checkup pour
    # pouvoir traiter au prochain tour tous les messages qui auront
    # été créés pendant le processus courant.
    update_last_time_checkup

    # Table pour conserver les sujets déjà traités. Un sujet n'a besoin
    # que d'un traitement.
    @sujets_deja_traited = {}

    # On traite chaque nouveau message du forum en envoyant une alerte
    # aux abonnés du sujets, sauf si une alerte leur a déjà été envoyée
    new_messages.each do |dmessage|

      log "- Traitement du message #{dmessage[:id]}"

      # Le post dont il est question
      ipost = Forum::Post::get(dmessage[:id])

      # L'identifiant du sujet du message
      sujet_id  = dmessage[:sujet_id].to_i

      # S'en retourner sans rien faire si ce sujet a déjà été
      # traité.
      next if @sujets_deja_traited[sujet_id] == true
      # Sinon on marque qu'il a déjà été traité
      @sujets_deja_traited.merge!(sujet_id => true)

      # Le sujet auquel appartient le message
      sujet = ( Forum::Sujet::get sujet_id )

      # La liste des abonnés à ce sujet
      followers = sujet.followers

      # S'en retourner sans rien faire si la liste est nil ou vide
      if followers.empty?
        log "  Aucun followers de ce sujet"
        next
      else
        log "  Nombre de followers de ce sujet : #{followers.count} (#{followers.join(', ')})"
      end

      # Lien pour lire le message
      href = "#{site.distant_url}/sujet/#{sujet_id}/read?in=forum&pid=#{ipost.id}"

      # Le message qui doit être envoyé aux followers pour leur
      # annoncer le nouveau  post sur le forum.
      message_annonce_new_post = <<-HTML
      <p>Bonjour %{pseudo},</p>
      <p>Je vous informe qu'un nouveau message à propos du sujet “#{sujet.name}” vient d'être rédigé par <strong>#{ipost.auteur.pseudo}</strong>.</p>
      <p>Pour le lire, rejoignez le lien :</p>
      <p><a href="#{href}">#{href}</a></p>
      <p>Bonne lecture !</p>
      HTML

      log "  Envoi du message d'annonce aux followers"
      followers.each do |follower_id|

        # Normalement, sur les autres sites, on ne prévient pas
        # l'auteur du message, même s'il fait partie de la liste des
        # followers. Personnellement, je préfère le prévenir, afin qu'il
        # ne se demande pas si son message a bien été reçu. D'autre part
        # puisqu'il faut une validation, c'est une manière pour lui aussi
        # de savoir que son message a été validé.

        # Vérifier si l'abonné a déjà reçu une alerte pour un message
        # précédent dans le même sujet (s'en retourner si oui). Cette vérification
        # se fait à l'aide de la table sujets_followers, pour les données où
        # l'user_id et le sujet_id sont tous les deux définis.
        where_clause = "sujet_id = #{sujet_id} AND user_id = #{follower_id}"
        next if Forum::table_follows.count(where: where_clause) > 0

        # Le destinataire du message. On a besoin d'en faire une
        # instance pour remplir les données du template de mail
        destinataire = User::get(follower_id)

        # Envoyer le mail à l'abonné
        destinataire.send_mail(
          subject: "Nouveau message sur le forum",
          message: (message_annonce_new_post % {pseudo: destinataire.pseudo})
        )

        # Enregistrer que l'abonné a reçu une alerte pour ce message
        # dans ce sujet
        Forum.table_follows.insert( {user_id: follower_id, sujet_id: sujet_id, time: NOW} )

      end # / fin de boucle sur les followers du sujet
    end

  rescue Exception => e
    error_log e, "Impossible de checker les nouveaux messages forum"
  ensure
    log "=== Fin du check des nouveaux messages du forum ===\n"
  end

  # Time de dernier checkup (n'est jamais nil car on met toujours au
  # moins le time d'il y a une heure)
  def last_time_checkup
    @last_time_checkup ||= site.get_last_date(:last_checkup_messages_forum, Time.now.to_i - 3600)
  end
  def update_last_time_checkup
    site.set_last_date(:last_checkup_messages_forum)
  end

  private

    # +err+ Une instance d'erreur
    def add_error message, err
      @errors ||= Array::new
      @errors << {mess:message, error:err}
    end

end #/ << self
end #/Forum
