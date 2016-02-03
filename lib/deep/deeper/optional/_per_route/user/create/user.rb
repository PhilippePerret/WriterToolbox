# encoding: UTF-8
=begin
Extension de la classe User pour créer l'utilisateur après son inscription
valide
=end

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
    # Méthode appelée par le formulaire pour inscrire
    # l'utilisateur
    # Si la création réussit :
    #  * Si une page suivante est définie (par exemple pour payer l'abonnement)
    #    on la rejoint
    #  * NON : CONFIRMATION REQUIRED Sinon on l'identifie et on affiche sa page
    #  * Sinon on revient à la page d'inscription (redirection)
    def create
      debug "-> User::create"
      newuser = User::new
      if newuser.create
        # newuser.login # NON Il doit confirmer avant
        site.user_prov = newuser
        redirect_to param(:route_after_signup) unless param(:route_after_signup).empty?
      end
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Instance User
  # ---------------------------------------------------------------------
  def create
    debug "-> User#create"
    if data_valides?
      # Les données sont valides on peut vraiment créer le
      # nouvel utilisateur.
      save_all_data
      # On envoie à l'utilisateur un message pour qu'il confirme
      # son adresse-mail.
      send_mail(
        subject: "Confirmez votre inscription",
        message: SuperFile::new(_"mail_confirmation.erb").deserb(self)
      )
      true
    else
      # Les données sont invalides, on doit rediriger vers
      # la page du formulaire d'inscription (user/signup)
      # Il y a peut-être un contexte, comme lorsque l'on crée
      # l'user pour un programme UN AN UN SCRIPT.
      # redirect_to 'user/signup'
      redirection = "user/signup"
      unless site.current_route.context.nil?
        redirection += "?in=#{site.current_route.context}"
      end
      redirect_to redirection
      false
    end
  end

  # Méthode appelée par le mail de confirmation de l'inscription
  # et du mail pour permettre à l'user de confirmer son inscription.
  # La méthode crée un ticket de confirmation et donne le lien au
  # mail
  def lien_confirmation_inscription
    debug "-> lien_confirmation_inscription"
    code = "User::get(#{id}).confirm_mail"
    app.create_ticket(nil, code, {user_id: id})
    # On retourne le lien de confirmation
    app.lien_ticket("Confirmation de votre inscription/mail").freeze
  end

  # Méthode qui sauve toutes les données de l'user d'un coup
  # Note : pour le moment, on n'utilise cette méthode que dans
  # ce module consacré à la création.
  # Cela renvoie l'ID, en tout cas si tout a bien fonctionné.
  def save_all_data
    @id = User::table_users.insert(data_to_save)
  end

  # Les données inégrales à sauver
  def data_to_save
    now = Time.now.to_i
    @data_to_save ||= {
      pseudo:       pseudo,
      patronyme:    patronyme,
      sexe:         sexe,
      mail:         mail,
      cpassword:    cpassword,
      salt:         random_salt,
      session_id:   app.session.session_id,
      created_at:   now,
      updated_at:   now
    }
  end

  # Retourne true si les données sont valides
  def data_valides?
    # Validité du PSEUDO
    @pseudo = form_data[:pseudo].nil_if_empty
    raise "Il faut fournir le pseudo."                    if @pseudo.nil?
    raise "Ce pseudo est déjà utilisé, merci d'en choisir un autre" if pseudo_exist?(@pseudo)
    raise "Le pseudo doit faire moins de 40 caractères."  if @pseudo.length >= 40
    raise "Le pseudo doit faire au moins 3 caractères."   if @pseudo.length < 3

    # Validité du patronyme
    @patronyme = form_data[:patronyme].nil_if_empty
    raise "Il faut fournir le patronyme." if @patronyme.nil?
    raise "Le patronyme ne doit pas faire plus de 255 caractères." if @patronyme.length > 255
    raise "Le patronyme ne doit pas faire moins de 3 caractères." if @patronyme.length < 3

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
    raise "Le captcha est mauvais, seriez-vous un robot ?" if captcha.to_i != 365

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
