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
  def initialize

  end

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
    destinataires.each do |writer|
      @auteur = writer # pour le déserbage
      data_mail = {
        to:       writer.mail,
        subject:  'B.O.A. UN AN UN SCRIPT - ' + ERB.new(prepared_subject).result(bind),
        message:  ERB.new(prepared_message).result(bind),
        # force_offline: true,
        no_header_subject: true,
        formated: true
      }
      # debug "\n\n-- data_mail : #{data_mail.pretty_inspect}"
      site.send_mail(data_mail)
      @nombre_messages += 1
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
  def destinataires
    @destinataires ||= begin
      if envoi_tous?
        Unan.auteurs(as: :instance, current: true)
      else
        [destinataire]
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
    @pour_message_type = data[:memorize] == 'on'
  end
  def envoi_tous?
    true == destinataire.nil?
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


end #/Contact
end #/UnanAdmin

case param(:operation)
when 'soumettre_contact_form'
  UnanAdmin::Contact.submit
end
