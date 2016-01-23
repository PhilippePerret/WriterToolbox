# encoding: UTF-8
class ::User

  # Pour ajouter une erreur
  def add_error mess_err
    @errors << mess_err
  end

  # Procédure principale qui inscrit l'user au programme UN AN UN SCRIPT
  # tout de suite après le paiement de son module.
  #
  # Note : c'est une procédure hyper protégée (mode sans échec) pour
  # aller jusqu'au bout et pouvoir corriger les problèmes au cas où.
  def signup_program_uaus

    # Pour consigner toutes les erreurs qui sont survenues et
    # pouvoir y remédier.
    # À l'intérieur d'une autre méthode ou de l'instance
    # user, utiliser la méthode `auteur.add_error "<erreur>"` ou
    # `user.add_error "<erreur>"`
    @errors = Array::new

    # On crée le programme de l'user et son projet
    create_program_et_projet

    # Création des tables du programme
    begin
      create_tables_1a1s
    rescue Exception => e
      @errors << "Les tables du programme n'ont pas pu être créés"
    end

    # Définition du premier p-day (jour-programme)
    begin
      instancier_premier_jour_programme
    rescue Exception => e
      @errors << "Le premier jour-programme n'a pas pu être instancié."
    end

    # Envoi des mails à l'user pour lui confirmer les
    # choses
    begin
      send_mail_confirmation_inscription_uaus
    rescue Exception => e
      @errors << "Les mails de confirmation n'ont pas pu être envoyés."
    end

    # Signaler les erreurs au cas où
    unless @errors.empty?
      error "Des erreurs sont malheureusement survenues au cours de votre inscription (merci de les signaler à l'administration, qui s'efforcera de régler le problème) :"
      error @errors.collect { |merr| merr.in_div }.join
    end

    # pour les tests
    return program_id
  end

  def create_program_et_projet
    begin
      folder_signup.require
    rescue Exception => e
      @errors << "Impossible de requérir le dossier signup : #{e.message}"
      return
    end
    begin
      # Création du programme (dans la table générale des programmes)
      @program_id = Unan::Program::create
    rescue Exception => e
      @errors << "Impossible de créer le programme : #{e.message}. Le projet ne sera pas créé non plus."
      return
    end
    begin
      # Création du projet (dans la table générale des projets)
      @projet_id  = Unan::Projet::create
    rescue Exception => e
      @errors << "Impossible de créer le projet : #{e.message}"
    end
  end

  # Instancier le premier jour programme
  def instancier_premier_jour_programme
    Unan::require_module 'start_pday'
    StarterPDay::new(program).activer_first_pday
  rescue Exception => e
    @errors << "Impossible d'instancier le premier jour-programme : #{e.message}"
  end

  # Envoyer les mails de confirmation d'inscription à l'user et
  # à l'administration du site
  def send_mail_confirmation_inscription_uaus

    les_mails_pour_error = ["Confirmation inscription", "Explications programme", "Annonce administration"]

    mail_confirmation = folder_signup + 'mail_confirmation_user.erb'
    data_mail = {
      to:       self.mail,
      subject:  "Confirmation inscription",
      message:  mail_confirmation.deserb( self ),
      formated: true
    }
    Unan::send_mail( data_mail )
    les_mails_pour_error.shift

    mail_explication = folder_signup + 'mail_explication_user.erb'
    data_mail = {
      to:       self.mail,
      subject:  "Premières explications",
      message:  mail_explication.deserb( self ),
      formated: true
    }
    Unan::send_mail( data_mail )
    les_mails_pour_error.shift

    mail_to_admin = folder_signup + 'mail_to_admin.erb'
    data_mail = {
      from:     self.mail,
      subject:  "Nouvelle inscription (##{self.id})",
      message:  mail_to_admin.deserb( self ),
      formated: true
    }
    Unan::send_mail( data_mail )
    les_mails_pour_error.shift

  rescue Exception => e
    @errors << "Problème en envoyant les mails : #{e.message} (mails non envoyé : #{les_mails_pour_error.pretty_join})"
  end

  def folder_signup
    @folder_signup ||= Unan::folder_modules + 'signup'
  end

end
