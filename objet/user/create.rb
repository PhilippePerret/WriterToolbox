# encoding: UTF-8
=begin
Extension de la classe User pour créer l'utilisateur après son inscription
valide
=end

User.require_module 'create'

class SiteHtml
  # Puisque l'user créé ne va pas être mis en user courant (car son mail
  # doit d'abord être confirmé), on le met dans cette variable pour
  # pouvoir être utilisé à l'affichage du message de bienvenue.
  attr_accessor :user_prov
end

class User
  # ---------------------------------------------------------------------
  #   Classe User
  # ---------------------------------------------------------------------
  class << self
    # Méthode appelée par le formulaire pour inscrire l'utilisateur
    # Si la création réussit, on doit attendre CONFIRMATION DE L'ADRESSE
    # MAIL avant la validation complète de l'user. SAUF s'il s'agit d'un
    # abdonnement dans lequel cas on envoie vers la page de paiement.
    # Les deux cas qui peuvent se produire sont :
    #   - l'user a coché la case "s'abonner" et donc on le redirige vers
    #     le paiement
    #   - une adresse a été transmise pour rediriger vers le paiement (mais
    #     je crois que c'est une vieille tournure qui n'a plus cours maintenant)
    # SI L'INSCRIPTION EST INVALIDE, on revient tout simplement à la page
    # d'inscription (redirection) pour que l'user recommence.
    def create pour_unanunscript = false
      newuser = User.new
      if newuser.create
        newuser.login
        if param(:user) && param(:user)[:subscribe] == 'on'
          # Pour passer outre la confirmation du mail, on
          # doit préciser que l'user procède à son paiement
          app.session['for_paiement'] = "1"
          # newuser.login # avant ICI
          if pour_unanunscript
            # => Page de paiement du programme UN AN
            redirect_to 'unan/paiement'
          else
            # => Page de paiement de l'ABONNEMENT au site
            redirect_to 'user/paiement'
          end
        else
          # On le met en user provisoire (pour l'accueillir dans
          # la prochaine page) mais il doit confirmer son email
          # tout de suite.
          site.user_prov = newuser
          unless param(:route_after_signup).empty?
            redirect_to param(:route_after_signup)
          end
        end
      end
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Instance User
  # ---------------------------------------------------------------------
  def create
    debug "-> create"
    if data_valides?
      debug "  = data_valides"

      # Les données sont valides on peut vraiment créer le
      # nouvel utilisateur.
      save_all_data

      # On envoie un mail à l'utilisateur pour confirmer son
      # inscription.
      begin
        debug "  * Envoi du mail de bienvenue"
        pmail = User.folder_modules + 'create/mail_bienvenue.erb'
        send_mail(
          subject: 'Bienvenue !',
          message: pmail.deserb(self),
          formated: true
        )
        debug "  = mail de bienvenue OK"
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL DE BIENVENUE"
        debug e
      end

      # On envoie à l'utilisateur un message pour qu'il confirme
      # son adresse-mail.
      debug "  * Envoi du mail de confirmation du mail"
      begin
        pmail = User.folder_modules + 'create/mail_confirmation.erb'
        send_mail(
          subject: 'Merci de confirmer votre mail',
          message: pmail.deserb(self),
          formated: true
        )
        debug "  = mail de confirmation adresse-mail OK"
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL DE CONFIRMATION"
        debug e
      end

      # On envoie un mail à l'administration pour informer
      # de l'inscription
      begin
        debug "  * Envoi du mail de nouvelle inscription"
        pmail = User.folder_modules + 'create/mail_admin.erb'
        User.get(1).send_mail(
          subject:  'Nouvelle inscription',
          message:  pmail.deserb(self),
          formated: true
        )
        debug "  = mail de Nouvelle inscription OK"
      rescue Exception => e
        debug "### PROBLÈME À L'ENVOI DU MAIL D'ANNONCE DE NOUVELLE INSCRIPTION"
        debug e
      end
      true
    else
      debug "  = Données invalides"

      # Les données sont invalides, on doit rediriger vers
      # Il y a peut-être un contexte, comme lorsque l'on crée
      # l'user pour un programme UN AN.
      redirection = BOA.rel_signup_path
      unless site.current_route.context.nil?
        redirection += "?in=#{site.current_route.context}"
      end
      redirect_to redirection
      false
    end
  end

  # Méthode qui sauve toutes les données de l'user d'un coup
  # Note : pour le moment, on n'utilise cette méthode que dans
  # ce module consacré à la création.
  # Cela renvoie l'ID, en tout cas si tout a bien fonctionné.
  def save_all_data
    @id = User.table_users.insert(data_to_save)
  end

  # Les données inégrales à sauver
  def data_to_save
    now = Time.now.to_i
    @data_to_save ||= {
      pseudo:       real_pseudo,
      patronyme:    patronyme,
      sexe:         sexe,
      mail:         mail,
      cpassword:    cpassword,
      salt:         random_salt,
      session_id:   app.session.session_id,
      options:      '0'*10,
      created_at:   now,
      updated_at:   now
    }
  end

  # Retourne le pseudo avec toujours la première
  # lettre capitalisée (mais on ne touche pas aux autres)
  def real_pseudo
    pseudo[0].upcase + pseudo[1..-1]
  end

  # Retourne true si les données sont valides
  def data_valides?
    # Validité du PSEUDO
    @pseudo = form_data[:pseudo].nil_if_empty
    ! @pseudo.nil? || raise( "Il faut fournir votre pseudo." )
    ! pseudo_exist?(@pseudo) || raise("Ce pseudo est déjà utilisé, merci d'en choisir un autre")
    @pseudo.length < 40 || raise("Ce pseudo est trop long. Il doit faire moins de 40 caractères.")
    @pseudo.length >= 3 || raise("Ce pseudo est trop court. Il doit faire au moins 3 caractères.")

    reste = @pseudo.gsub(/[a-zA-Z0-9_\-]/,'')
    reste == "" || raise("Ce pseudo est invalide. Il ne doit comporter que des lettres, chiffres, traits plats et tirets. Il comporte les caractères interdits : #{reste.split.pretty_join}")
    # Validité du patronyme
    @patronyme = form_data[:patronyme].nil_if_empty
    raise "Il faut fournir votre patronyme." if @patronyme.nil?
    raise "Le patronyme est trop long. Il ne doit pas faire plus de 255 caractères." if @patronyme.length > 255
    raise "Le patronyme est trop court. Il ne doit pas faire moins de 3 caractères." if @patronyme.length < 3

    # Validité du mail
    @mail = form_data[:mail].nil_if_empty
    raise "Il faut fournir votre mail." if @mail.nil?
    raise "Ce mail est trop long." if @mail.length > 255
    raise "Ce mail n'a pas un bon format de mail." if @mail.gsub(/^[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}$/,'') != ""
    raise "Ce mail existe déjà… Vous devez déjà être inscrit…" if mail_exist?( @mail )
    raise "La confirmation du mail ne correspond pas." if @mail != form_data[:mail_confirmation]

    # Validité du mot de passe
    @password = form_data[:password].nil_if_empty
    raise "Il faut fournir un mot de passe." if @password.nil?
    raise "Le mot de passe ne doit pas excéder les 40 caractères." if @password.length > 40
    raise "Le mot de passe doit faire au moins 8 caractères." if @password.length < 8
    raise "La confirmation du mot de passe ne correspond pas." if @password != form_data[:password_confirmation]

    # On variabilise les choses non testées
    @sexe = form_data[:sexe].nil_if_empty
    raise "Le sexe devrait être défini." if @sexe.nil?
    raise "Le sexe n'a pas la bonne valeur." unless ['F', 'H'].include?(@sexe)

    captcha = form_data[:captcha].nil_if_empty
    raise "Il faut fournir le captcha pour nous assurer que vous n'êtes pas un robot." if captcha.nil?
    raise "Le captcha est mauvais, seriez-vous un robot ?" if captcha.to_i != 366

  rescue Exception => e
    debug "# #{e.message}"
    error e.message
  else
    true
  end

  # Les données en paramètres (dans le formulaire)
  def form_data
    @form_data ||= param(:user)
  end

  # Retourne le mot de passe crypté
  def cpassword
    @cpassword ||= begin
      require 'digest/md5'
      Digest::MD5.hexdigest("#{@password}#{mail}#{random_salt}")
    end
  end

  # Retourne un nouveau sel pour le mot de passe crypté
  # C'est un mot de 10 lettres minuscules choisies au hasard
  def random_salt
    @random_salt ||= 10.times.collect{ |itime| (rand(26) + 97).chr }.join('')
  end

  # Return true si le pseudo existe
  def pseudo_exist? pseudo
    return table_users.count(where: "pseudo = '#{pseudo}'") > 0
  end

  # Return True si le mail +mail+ se trouve déjà dans la table
  def mail_exist? mail
    return table_users.count(where: "mail = '#{mail}'") > 0
  end

end
