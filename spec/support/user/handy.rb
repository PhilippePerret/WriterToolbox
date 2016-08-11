# encoding: UTF-8
=begin
Handy méthodes pour les user
=end

# alias def identify
def go_and_identify mail, password = nil
  mail, password =
    case mail
    when String then [mail, password]
    when Hash   then [mail[:mail], mail[:password]]
    else raise 'Format de mail incorrect pour une identification'
    end

  visit_home
  click_link('S\'identifier')
  expect(page).to have_css('form#form_user_login')
  within('form#form_user_login') do
    fill_in('login_mail', with: mail)
    fill_in('login_password', with: password)
    click_button('OK')
  end
end
alias :identify :go_and_identify

def identify_phil
  require './data/secret/data_phil'
  go_and_identify DATA_PHIL[:mail], DATA_PHIL[:password]
  puts "Phil s'identifie"
end
def identify_benoit
  require './data/secret/data_benoit'
  go_and_identify DATA_BENOIT[:mail], DATA_BENOIT[:password]
  puts "Benoit s'identifie"
end

# Retourne un pseudo aléatoire d'une longeur de 6 à 16 lettres
# à peu près
def random_pseudo
  # Longeur aléatoire
  len_pseudo = 6 + rand(10)
  # Première lettre
  pse = (65 + rand(26)).chr
  liste_voyelles = ['a','e', 'i', 'o', 'u', 'y', 'oi'].freeze
  nombre_voyelles = liste_voyelles.count
  # Lettres suivantes
  (len_pseudo/2).times do
    pse << liste_voyelles[rand(nombre_voyelles)]
    pse << (97 + rand(26)).chr
  end
  return pse
end

# {User} Retourne une instance User prise au hasard sur le site
#
# +options+
#   :but    Array des IDs à ne pas utiliser
#   :with_program   Si true, l'auteur doit avoir un programme 1a1s
#   :with_forum_messages
#     Si true, il faut trouver un utilisateur qui a des messages sur
#     le forum.
#
def get_any_user options = nil

  options ||= Hash::new
  ids, where = nil, Array::new

  if options[:with_program]
    # => Il faut retourner un user qui suit un programme, donc il faut
    # prendre les ids dans la table des programmes.
    programs = Unan::table_programs.select(where: "options LIKE '1%'", colonnes:[:auteur_id])
    ids = programs.collect{|hp| hp[:auteur_id]}
  end

  if options[:but] && !options[:but].empty?
    where << "id NOT IN (#{options[:but].join(', ')})"
  end

  where = if where.empty?
    nil
  else
    where.join(' AND ')
  end

  if ids.nil?
    ids = if where.nil?
      User::table.select(colonnes:[:id]).keys
    else
      User::table.select(where:where, colonnes:[:id]).keys
    end
  end

  if options[:with_messages_forum] && !ids.empty?
    # Il faut que les users choisis possèdent des messages sur le
    # forum
    res = Forum::table_posts.select(colonnes:[:user_id], where:"user_id IN (#{ids.join(',')})")
    ids = res.values.collect{|h| h[:user_id]}
    raise "Impossible de trouver des users avec des messages forum…" if ids.empty?
  end

  raise "Impossible de trouver des users répondant aux conditions…" if ids.empty?

  uid = ids.shuffle.shuffle.first
  u = User.new(uid)
  expect(u).to be_instance_of(User)
  return u
end

def phil
  u = User.new(1)
  expect(u).to be_instance_of(User)
  expect(u).to be_admin
  return u
end

def benoit
  u = User.new(2)
  expect(u).to be_instance_of(User)
  return u
end

# Retourne des données au hasard mais valides pour un
# user. Le hash retourné contient toutes les données
# utiles pour le formulaire d'inscription.
def random_user_data mail = nil, password = nil
  now       = Time.now.to_i
  sexe      = ["H","F"][rand(2)]
  hsexe     = {'H' => 'un homme', 'F' => 'une femme'}[sexe]
  prenom    = UserSpec::random_prenom(sexe)
  salt      = "dubonsel"
  mail      ||= "mail#{sexe}#{now}@chez.moi"
  password  ||= "unmotdepasse"
  cpassword = Digest::MD5.hexdigest("#{password}#{mail}#{salt}")

  {
    pseudo:     "#{prenom.normalized}#{sexe}",
    patronyme:  "#{prenom} Patro #{sexe} N#{now}",
    mail:       mail,
    sexe:       sexe,
    hsexe:      hsexe,
    options:    "001000000000000000",
    salt:       salt,
    password:   password,
    cpassword:  cpassword
  }
end

# +options+
#
#   :unanunscript   Si true, l'inscrit au programme
#   :subscriber     Si true, crée un abonné
#   :current        Si true, le met en user courant
#
#   Toutes les autres propriétés servent à décrire les
#   données de l'user, qui seront enregistrées dans la
#   table
def create_user options = nil
  require 'digest/md5'
  now = Time.now.to_i
  options ||= Hash.new

  # Retirer les valeurs qui ne doivent pas être enregistrées
  programme_1a1s = options.delete(:unanunscript)
  subscriber     = options.delete(:subscriber) == true
  mettre_courant = options.delete(:current) || programme_1a1s

  druser = random_user_data

  options[:sexe]        ||= druser[:sexe]
  options[:pseudo]      ||= druser[:pseudo]
  options[:patronyme]   ||= druser[:patronyme]
  options[:mail]        ||= druser[:mail]
  options[:options]     ||= druser[:options]
  options[:session_id] = app.session.session_id unless options.key?(:session_id)
  options[:created_at]  ||= now
  options[:updated_at]  ||= now

  pwd = options.delete(:password) || druser[:password]
  options[:salt]        ||= druser[:salt]
  cpwd = Digest::MD5.hexdigest("#{pwd}#{options[:mail]}#{options[:salt]}")
  options[:cpassword] = cpwd


  @id = User.table_users.insert(options)
  new_user = User.get(@id)
  # debug "ID du nouvel user créé par `create_user` des tests : #{new_user.id.inspect}"

  # Mettre en courant lorsqu'on en a fait explicitement la
  # demande ou lorsqu'un programme UN AN UN SCRIPT doit être
  # instancié pour l'auteur.
  User.current= new_user if mettre_courant || programme_1a1s

  # Si l'user doit être inscrit au programme UN AN UN SCRIPT, il
  # faut simuler son inscription au niveau des autorisations
  if subscriber || programme_1a1s
    if programme_1a1s
      site.require_objet 'unan'
      (Unan.folder_modules + 'signup_user.rb').require
      new_user.signup_program_uaus
    end
    data_autorisation = {
      user_id: new_user.id,
      raison: (programme_1a1s ? '1AN1SCRIPT' : 'ABONNEMENT'),
      start_time: now - 3600,
      end_time:   (now - 3600) + ((programme_1a1s ? 2 : 1) * 365.days),
      created_at: now - 3600,
      updated_at: now - 3600,
      nombre_jours: (2 * 365)
    }
    User.table_autorisations.insert(data_autorisation)

    now = Time.now.to_i
    data_paiement = {
      user_id:    new_user.id,
      objet_id:   (programme_1a1s ? '1AN1SCRIPT' : 'ABONNEMENT'),
      montant:    (programme_1a1s ? Unan.tarif : site.tarif),
      facture:    'EC-38P44270A51102219',
      created_at:  now
    }
    table_paiements = site.dbm_table(:cold, 'paiements')
    table_paiements.insert(data_paiement)
  end

  return new_user

end

# Détruit des users dans la table offline, sans toucher aux 10
# premiers
#
def remove_users upto = :all
  drequest = {
    where: "id > 3",
    colonnes: []
  }
  case upto
  when Fixnum then drequest.merge!(limit: upto)
  when :all
    # Rien à faire
  end

  ids = User.table.select(drequest).collect{|h| h[:id]}

  # On les détruit dans la table
  User.table.delete(drequest)

  # On les détruit dans la table des paiements
  User.table_paiements.delete(drequest)

  # On les détruit dans la table des autorisations
  User.table_autorisations.delete(drequest)

end
