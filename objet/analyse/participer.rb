# encoding: UTF-8
class FilmAnalyse
class << self
  def proposer_participation
    if param(:proposition_participation_sent) == "1"
      return error "Vous avez déjà transmis votre demande de participation."
    end
    check_data_participer || (return false)
    data_mail = {
      from:       datap[:mail],
      subject:    "Proposition de participation aux analyses de film",
      message:    message_proposition,
      formated:   true
    }
    ( site.send_mail data_mail )
    flash "Merci de votre proposition. Phil va prendre très rapidement contact avec vous."
    app.session['proposition_participation_sent'] = "1"
  end

  def datap
    @datap ||= begin
      d = param(:participer)
      d.merge!(mail_current_user: user.mail)
      d
    end
  end

  # Retourne true si les données sont correctes, false dans le cas
  # contraire.
  def check_data_participer

    # Le pseudo
    unless user.identified?
      pseudo = datap[:pseudo].nil_if_empty
      @datap[:pseudo] = ""
      raise "Il faut fournir un pseudo, s'il vous plait." if pseudo.nil?
      raise "Le pseudo `#{pseudo}` est déjà utilisé, merci d'en choisir un autre" if pseudo_exist?(pseudo)
      raise "Votre pseudo ne doit pas excéder les 40 caractères." if pseudo.length > 40
      raise "Votre pseudo doit faire au moins 3 caractères." if pseudo.length < 3
      reste = pseudo.gsub(/[a-zA-Z_\-]/,'')
      raise "Votre pseudo ne doit comporter que des lettres, traits plats et tirets. Il comporte les caractères interdits #{reste.split('').pretty_join}." if reste != ""
      @datap[:pseudo] = pseudo
    end

    # Le mail
    unless user.identified?
      mail = datap[:mail].nil_if_empty
      @datap[:mail] = ""
      raise "Il faut fournir votre mail !" if mail.nil?
      raise "Ce mail est déjà utilisé par un autre utilisateur. Merci de vous identifier si c'est vous." if mail_exist?(mail)
      @datap[:mail] = mail
      mail_conf = datap[:mail_confirmation].nil_if_empty
      raise "Il faut fournir la confirmation du mail !" if mail_conf.nil?
      raise "La confirmation du mail ne correspond pas au mail." if mail != mail_conf
      @datap[:mail_confirmation] = mail_conf
    end

    # La raison
    raison = datap[:raison].nil_if_empty
    raise "Merci d'indiquer la raison qui vous pousse à vouloir participer, même en quelques mots." if raison.nil?
    @datap[:raison] = raison

  rescue Exception => e
    param( :participer => @datap )
    error e.message
  else
    true
  end

  # Return true si le pseudo existe
  def pseudo_exist? pseudo
    return User::table_users.count(where: {pseudo: pseudo}) > 0
  end

  # Return True si le mail +mail+ se trouve déjà dans la table
  def mail_exist? mail
    return User::table_users.count(where: {mail: mail}) > 0
  end

  # Message qui sera envoyé à l'administration pour l'informer
  # qu'un visiteur veut participer aux analyses.
  def message_proposition
    elle = ( user.identified? && user.femme? ) ? 'elle' : 'lui'
    <<-HTML
<p>Bonjour Phil,</p>
<p>Je t'informe de la volonté de #{datap[:pseudo]} de participer aux analyses de films.</p>
<p>Merci de prendre contact avec #{elle}.</p>
<table>
  <tr>
    <td>Pseudo</td><td>#{datap[:pseudo]}</td>
  </tr><tr>
    <td>Mail</td><td><a href="mailto:#{datap[:mail]}">#{datap[:mail]}</a></td>
  </tr>
  <tr>
    <td>Raison</td>
    <td>#{datap[:raison]}</td>
  </tr>
</table>
    HTML
  end
end # << self
end # FilmAnalyse

case param(:operation)
when 'proposer_participation'
  debug "-> FilmAnalyse::proposer_participation"
  FilmAnalyse.proposer_participation
end
