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

    debug "\n\n=== INSTANCIATION D'UN PROGRAMME UN AN UN SCRIPT ===\n\n"
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
      @errors << "Les tables du programme n'ont pas pu être créés : #{e.message}"
      debug "# IMPOSSIBLE DE CRÉER LES TABLES 1A1S : #{e.message}\n\n"+e.backtrace.join("\n")
    end

    # Définition du premier p-day (jour-programme)
    begin
      instancier_premier_jour_programme
    rescue Exception => e
      @errors << "Le premier jour-programme n'a pas pu être instancié."
      debug "# IMPOSSIBLE D'INSTANCIER LE PREMIER JOUR-PROGRAMME : #{e.message}\n\n"+e.backtrace.join("\n")
    end

    # Envoi des mails à l'user pour lui confirmer les
    # choses
    begin
      send_mail_confirmation_inscription_uaus
    rescue Exception => e
      @errors << "Les mails de confirmation n'ont pas pu être envoyés."
      debug "# IMPOSSIBLE D'ENVOYER LE MAIL DE CONFIRMATION D'INSCRIPTION AU PROGRAMME 1A1S : #{e.message}\n\n"+e.backtrace.join("\n")
    end

    # Signaler les erreurs au cas où
    if @errors.empty?
      debug "=== PROGRAMME 1 AN 1 SCRIPT INSTANCIÉ AVEC SUCCÈS ==="
    else
      error "Des erreurs sont malheureusement survenues au cours de votre inscription (merci de les signaler à l'administration, qui s'efforcera de régler le problème) :"
      error @errors.collect { |merr| merr.in_div }.join
    end

    # pour les tests
    return @program_id
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
      raise "@program_id (ID du programme créé) ne devrait pas être nil…" if @program_id.nil?
      debug "ID du nouveau programme : #{@program_id}"
      # On définit le programme pour ne pas avoir de problèmes par
      # la suite avec `user.program` ou `auteur.program`
      @program = Unan::Program::new(@program_id)
    rescue Exception => e
      @errors << "Impossible de créer le programme : #{e.message}. Le projet ne sera pas créé non plus."
      return
    end
    begin
      # Création du projet (dans la table générale des projets)
      @projet_id  = Unan::Projet::create
      raise "@projet_id (ID du projet créé) ne devrait pas être nil…" if @projet_id.nil?
      debug "ID du nouveau projet : #{@projet_id}"
    rescue Exception => e
      @errors << "Impossible de créer le projet : #{e.message}"
    end
  end

  # Instancier le premier jour programme
  def instancier_premier_jour_programme
    debug "user.get_var(:current_pday) = #{user.get_var(:current_pday).inspect}"
    Unan::require_module 'start_pday'
    Unan::Program::StarterPDay::new(program).activer_first_pday
    debug "P-Day courant du user : #{self.program.current_pday.inspect}"
    raise "Le jour courant de l'user devrait être 1" unless self.program.current_pday == 1
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
