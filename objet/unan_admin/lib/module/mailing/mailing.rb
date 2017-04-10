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

class UnanAdmin
class Contact
class << self

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
    @table_messages_type ||= site.dbm_table(:unan, 'messages_type')
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
    debug "destinataires.class = #{destinataires.class}"
    # Pour m'envoyer aussi le message
    require './data/secret/data_phil'
    hphil = {
      pseudo: "Phil", mail: DATA_PHIL[:mail],
      patronyme: "Philippe Perret", options: "37100000", sexe: 'H'
    }
    (destinataires << hphil).each do |hwriter|
      debug "\n\nWriter : #{hwriter[:pseudo]} (#{hwriter[:id]})"
      debug "#{hwriter.pretty_inspect}"
      @auteur = AuteurUnan.new(hwriter) # pour le déserbage
      data_mail = {
        to:                 @auteur.mail,
        subject:            "B.O.A.  - #{Unan::PROGNAME_MINI_MAJ}" + ERB.new(prepared_subject).result(bind),
        message:            ERB.new(prepared_message).result(bind),
        force_offline:      force_offline?,
        no_header_subject:  true,
        formated: true
      }
      # debug "\n\n-- data_mail : #{data_mail.pretty_inspect}"
      site.send_mail(data_mail)
      liste_pseudos << @auteur.pseudo
      @nombre_messages += 1
    end
    if OFFLINE && ! force_offline?
      flash "Le mail aurait été envoyé à #{liste_pseudos.pretty_join}."
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

  # Retourne une liste Array de Hash des données utiles
  # des auteurs.
  #
  # Noter qu'on ne travaille pas avec des instances User
  # car le module peut travailler avec des données online
  #
  def destinataires
    @destinataires ||= begin
      if envoi_tous?
        dauts = {as: :ids, current: true}
        dauts.merge!( real_writers: real_writers? ) if OFFLINE
        liste_ids = Unan.auteurs(dauts)
        tbl = site.dbm_table(:hot, 'users', online = real_writers?)
        tbl.select(where: "id IN (  #{liste_ids.join(', ')} )")
      else
        [destinataire.get_all]
      end
    end
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
  def real_writers?
    @for_real_writers = data[:real_writers] == 'on' if @for_real_writers === nil
    @for_real_writers
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
    @data ||= param(:contact)
  end

  # ---------------------------------------------------------------------
  #   Classe UnanAdmin::Contact::AuteurUnan
  #
  #   Classe qui répond aux variables dans le mail de type
  #   <%= auteur.pseudo %>
  #   On ne peut pas utiliser la classe User normal car il est
  #   possible qu'on soit en local et qu'on travaille avec des
  #   auteur du site distant (qui n'ont donc pas leurs données
  #   dans la base locale)
  #
  # ---------------------------------------------------------------------
  class AuteurUnan
    attr_reader :id, :pseudo, :patronyme, :mail, :options, :created_at
    def initialize data
      data.each{|k,v| instance_variable_set("@#{k}", v)}
    end
  end
end #/Contact
end #/UnanAdmin
