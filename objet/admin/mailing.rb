# encoding: UTF-8
raise_unless_admin
=begin

=end
# L'auteur, peut-être, à qui il faut envoyer le message
# Sinon, il faut l'envoyer à tous
def destinataire
  @destinataire ||= begin
    param(:uid).nil? ? nil : User.get(param(:uid).to_i)
  end
end
def set_destinataire u
  @destinataire = u
end

class Admin
class Mailing
class << self

  def apercu_mail; @apercu_mail end
  def apercu_mail= value; @apercu_mail = value end

  def add_output str
    flash "-> add_output"
    @output ||= String.new
    @output << str
  end

  # Sortie pour information
  # Ça peut être le mail envoyé ainsi que la liste des
  # destinataires
  def output
    (@output || '') + apercu_mail
  end

  # Méthode principale pour soumettre le formulaire
  # Soit pour envoyer le message, soit pour enregistrer un
  # nouveau message type
  def submit
    new().submit
  end

  # Retourne la liste des valeurs pour le menu des messages
  # type
  def menu_values_messages_type
    @menu_values_messages_type ||= begin
      [['', 'Choisir le message type…']] +
      table_messages_type.select(colonne:[:titre]).collect do |mtype|
        [mtype[:id], mtype[:titre]]
      end
    end
  end

  def table_messages_type
    @table_messages_type ||= site.dbm_table(:cold, 'messages_type')
  end
end #/ << self

  # ---------------------------------------------------------------------
  #   L'instance du mail à envoyer
  # ---------------------------------------------------------------------


  def submit
    check_data_or_raise || return
    if message_type?
      # Il faut simplement enregistrer le message
      flash 'Message type enregistré avec succès.'
    else
      prepare_mail        || return
      send                || return
      flash "Message envoyé avec succès ! (#{nombre_messages})"
    end
  end


  # ---------------------------------------------------------------------
  #   Méthodes d'envoi
  # ---------------------------------------------------------------------

  def send
    @nombre_messages = 0
    # Si on est offline et qu'on ne doit pas forcer l'envoi,
    # on écrit à qui aurait été envoyé le message.
    liste_pseudos = Array.new
    destinataires.each do |umailing|
      @auteur = umailing # pour le déserbage, class {UserMailing}
          # Noter que ça peut être aussi des icariens, eux aussi
          # de classe {UserMailing}

      data_mail = {
        to:                 @auteur.mail,
        subject:            ERB.new(prepared_subject).result(bind),
        message:            ERB.new(prepared_message).result(bind),
        force_offline:      force_offline?,
        formated: true
      }
      # debug "\n\n-- data_mail : #{data_mail.pretty_inspect}"
      if self.class.apercu_mail.nil?
        self.class.apercu_mail= ("Sujet: #{data_mail[:subject]}<br/>"+data_mail[:message]).in_fieldset(legend: "Aperçu du message")
      end
      site.send_mail(data_mail)
      liste_pseudos << @auteur.pseudo
      @nombre_messages += 1
    end
    if OFFLINE && !force_offline?
      flash "-> ici"
      liste_humaine =
        if liste_pseudos.empty?
          'personne'
        else
          liste_pseudos.pretty_join
        end
      self.class.add_output( "Le mail aurait été envoyé à #{liste_humaine}.".in_div)
    end
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  def nombre_messages
    @nombre_messages ||= 0
  end

  # Retourne les identifiants des abonnés dans la
  # table des paiements, en tenant compte du fait qu'on
  # cherche soit en local soit en distant
  def user_ids_abonned
    tbl_paiements = site.dbm_table(:cold, 'paiements', online = real_users?)
    ilya_un_an    = Time.new(Time.now.year - 1, Time.now.month, Time.now.day).to_i
    ilya_deux_ans = Time.new(Time.now.year - 2, Time.now.month, Time.now.day).to_i
    where = "( objet_id = 'ABONNEMENT' AND created_at > #{ilya_un_an} ) OR ( objet_id = '1AN1SCRIPT' AND created_at > #{ilya_deux_ans} )"
    tbl_paiements.select(where: where, colonnes: [:user_id]).collect{|h| h[:user_id]}
  end
  # Retourne une liste Array d'instance Admin::Mailing::UserMailing
  #
  # Noter qu'on ne travaille pas avec des instances User
  # car le module peut travailler avec des données online
  # Donc la méthode ne
  #
  def destinataires
    @destinataires ||= begin
      if envoi_tous?
        dauts = {as: :ids, current: true}
        dauts.merge!( real_users: real_users? ) if OFFLINE
        # La table des users, soit celle locale soit celle
        # distante en fonction des options choisies.
        tbl = site.dbm_table(:hot, 'users', online = real_users?)

        # Construction de la clause WHERE en fonction des
        # destinataires
        #
        # Clause where en fonction des users recherchés
        wclause =
          case data[:sent_to]
          when 'all'
            # Tous les inscrits/abonnés (donc sauf les détruits)
            nil # tout sauf détruit
          when 'abonned'
            # Les abonnés
            "id IN (#{user_ids_abonned.join(', ')})"
          when 'admins'
            "CAST(SUBSTRING(options,1,1) AS UNSIGNED) & 1 > 0"
          when 'purinscrits'
            "id NOT IN (#{user_ids_abonned.join(', ')})"
          when 'analystes'
            "SUBSTRING(options,18,1) = '1'"
          else raise "Type des destinataires inconnus : #{data[:sent_to]}"
          end
          # Ajouter qu'il ne faut pas prendre les détruits
        where_clause = ["SUBSTRING(options,4,1) != '1'"]
        where_clause << wclause unless wclause.nil?
        where_clause = where_clause.join(' AND ')

        # Traiter tous les users qui répondent à la
        # requête.
        # Noter qu'on prend toutes les données, car ce n'est
        # pas de vraies instances User qu'on fait (impossible avec
        # les users distants), c'est une classe d'utilisateur propre
        # au mailing (Admin::Mailing::UserMailing)
        #
        mails_out = Array.new
        dests =
          tbl.select(where: where_clause).collect do |huser|
            mails_out << huser[:mail]
            UserMailing.new(huser)
          end

        debug "Nombre de dests : #{dests.count}"

        dests += instances_icariens(mails_out) if data[:to_icariens] == 'on'

        # Tous les destinataires
        dests
      else
        # Sinon on retourne seulement le destinataire
        [destinataire]
      end
    end
  end

  # Méthode retournant une liste d'instance {UserMailing} des
  # icariens, si demandé par l'annonce
  #
  # Si le fichier sqlite distant existe, on l'utilise, sinon,
  # c'est que Icare fonctionne maintenant avec MySQL et on récupère
  # les données simplement avec Mysql2
  #
  def instances_icariens mails_out
    require 'sqlite3'
    dbpath = File.join('.', 'tmp', 'icariens.db')
    File.unlink dbpath if File.exist? dbpath
    dis_path = "www/storage/db/icariens.db"
    cmd = "scp serveur_icare:#{dis_path} ./tmp/icariens.db"
    `#{cmd}`
    if File.exist? dbpath
      # Options converties
      bit_admin   = '0' # sera réglé plus bas
      bit_forum   = '0' # grade forum
      bit_mail    = '0' # mail confirmé (réglé plus bas)
      bit_detruit = '0'
      options_converties = "#{bit_admin}#{bit_forum}#{bit_mail}#{bit_detruit}"
      options_converties = options_converties.ljust(32,'0')
      options_converties[31] = '1' # icarien

      # On crée toutes les instances UserMailing
      #
      # C'est ce collect qui est retourné
      get_icariens_as_hash(mails_out).collect do |ic_id, ic_data|
        # Les données utiles :
        # attr_reader :id, :pseudo, :patronyme, :mail, :options, :created_at

        # Le bit admin
        options_converties[0] = ic_id == 0 ? '1' : '0'
        options_converties[2] = ic_data[:confirmed] ? '1' : '0'
        UserMailing.new(
          id: ic_id,
          pseudo: ic_data[:pseudo], patronyme: ic_data[:pseudo],
          mail: ic_data[:mail], created_at: ic_data[:created_at],
          options: options_converties
        )
      end
    else
      error "Le fichier icariens.db n'a pas pu être downloadé, impossible de récupérer les icariens… Le message ne leur sera pas envoyé."
      []
    end
  end

  # Retourne un hash des icariens avec en clé leur identifiant
  # et en Hash leurs données
  def get_icariens_as_hash( mails_out )
    dbpath = File.join('.', 'tmp', 'icariens.db')
    db = SQLite3::Database.new(dbpath)
    icariens = Hash.new
    db.execute('SELECT * FROM icariens;').each do |arr_ic|
      id, mail, pseudo, sexe, mod_uid, icmodule_id, state, autres = arr_ic
      icariens.merge!(
      id.to_i => {
        id: id.to_i,
        mail: mail, pseudo: pseudo, sexe: sexe, state: state,
        options: nil, confirmed: nil
      }
      )
    end
    db.execute('SELECT * FROM complete_data;').each do |arr_ic|
      id, created_at, updated_at, naissance, pwd, cpwd, confirmed, options, autres = arr_ic
      icariens[id.to_i].merge!(
        options:    options,
        confirmed:  confirmed == 1
      )
    end

    # Les mails à retirer des envois, pour différentes raisons à commencer
    # par le fait que l'adresse n'existe plus.
    mails_out += [
      'domideso@hotmail.fr', 'rocha_dilma@hotmail.com',
      'mahidalila@aol.com'
    ]

    # On supprime les icariens qui ne veulent pas recevoir de
    # messages. Ce sont les icariens qui ont le troisième bit
    # d'option à 0 (donc le bit d'index 2)
    icariens.keys.each do |icid|
      dic = icariens[icid]
      if dic[:confirmed] == false
        exclu = icariens.delete(icid)
        debug "EXCLU NON CONFIRMÉ : #{exclu[:pseudo]}"
      elsif icariens[icid][:options][1] == '0'
        # Il faut exclure de la liste
        exclu = icariens.delete(icid)
        debug "EXCLU : #{exclu[:pseudo]} (#{exclu[:mail]})"
      elsif mails_out.include? icariens[icid][:mail]
        exclu = icariens.delete(icid)
        debug "MAIL EXCLU : #{exclu[:pseudo]} (#{exclu[:mail]})"
      end
    end

    icariens
  end

  def bind; binding() end

  # ---------------------------------------------------------------------
  #   Méthodes de données
  # ---------------------------------------------------------------------
  def subject ; @subject end
  def message ; @message end
  def format  ; @format ||= data[:format] end # 'htm', 'erb', 'md'
  def auteur
    @auteur ||= destinataire
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'état
  # ---------------------------------------------------------------------
  def message_type?
    @pour_message_type = data[:memorize] == 'on' if @pour_message_type === nil
    @pour_message_type
  end
  def envoi_tous?
    true == destinataire.nil?
  end
  # Renvoie true si l'on est en offline mais qu'il faut quand même
  # envoyer le message à tous les vrais auteurs.
  def real_users?
    @for_real_users = data[:real_users] == 'on' if @for_real_users === nil
    @for_real_users
  end
  # Renvoie true s'il faut forcer l'envoi même si on est
  # en offline
  def force_offline?
    @force_offline = data[:force_offline] == 'on' if @force_offline === nil
    @force_offline
  end

  # ---------------------------------------------------------------------
  #   Méthodes de vérification
  # ---------------------------------------------------------------------

  # Méthode de vérification des données
  def check_data_or_raise
    @message = data[:message].nil_if_empty
    message != nil || raise("Le message doit être fourni impérativement.")
    @subject = data[:subject].nil_if_empty
    subject != nil || raise('Le sujet du message doit impérativement être fourni, même pour un message type.')
    res = try_evaluation
    res.nil? || raise("Impossible d’évaluer le message et le sujet : #{res}. Voir le débug pour le détail.")
  rescue Exception => e
    debug e
    error e.message
  else
    true # pour poursuivre
  end

  # Méthode qui va essayer d'évaluer le message et le titre
  def try_evaluation
    # Si le destinataire n'est pas défini (envoi à tous), on prend
    # l'user courant
    no_destinataire = destinataire.nil?
    set_destinataire(user) if no_destinataire
    [subject, message].each do |foo|
      if foo.match(/<%=/)
        begin
          evaluate(foo)
        rescue Exception => e
          raise e
        end
      end
    end
    return nil
  rescue Exception => e
    debug e
    return e.message.gsub(/</,'&lt;')
  ensure
    # Retourner l'état initial
    set_destinataire(nil) if no_destinataire
  end

  # ---------------------------------------------------------------------
  #   Méthodes de construction du message
  # ---------------------------------------------------------------------
  def prepare_mail
    # Pour le moment, rien à faire, tout se gère de soi-même
    return true
  end
  # Le message préparé
  #
  # "Préparé" signifie qu'il ne restera que les balises
  # ERB à évaluer en fonction de l'auteur courant
  def prepared_message
    case format
    when 'htm', 'erb' then message
    when 'md'
      site.require_module 'kramdown'
      message.kramdown(output_format: :erb)
    end
  end
  def prepared_subject
    case format
    when 'htm', 'erb' then subject
    when 'md'
      site.require_module 'kramdown'
      subject.kramdown(output_format: :erb)
    end.sub(/^<p>/,'').sub(/<\/p>$/,'')
  end

  def evaluate ca
    ca.gsub(/<%(=)?(.*?)%>/){
      egal = $1
      code = $2
      code = code.strip unless code.nil?
      eval code
    }
  end


  def data
    @data ||= param(:mailing)
  end

  # ---------------------------------------------------------------------
  #   Classe Admin::Mailing::UserMailing
  #
  #   Classe qui répond aux variables dans le mail de type
  #   <%= auteur.pseudo %>
  #   On ne peut pas utiliser la classe User normal car il est
  #   possible qu'on soit en local et qu'on travaille avec des
  #   auteur du site distant (qui n'ont donc pas leurs données
  #   dans la base locale)
  #
  #   D'autre part, cette classe est aussi utilisée par les
  #   icariens quand il faut aussi leur envoyer l'annonce.
  #
  # ---------------------------------------------------------------------
  class UserMailing
    attr_reader :id, :pseudo, :patronyme, :mail, :options, :created_at
    def initialize data
      data.each{|k,v| instance_variable_set("@#{k}", v)}
    end
  end
end #/Contact
end #/UnanAdmin

case param(:operation)
when 'soumettre_contact_form'
  ::Admin::Mailing.submit
end
