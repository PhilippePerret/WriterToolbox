# encoding: UTF-8
=begin
Méthodes de statut pour l'utilisateur (courant ou autre)
=end
class User

  # Pour savoir si c'est googlebot qui visite le
  # site
  REG_DNS_GOOGLE = /^66\.249\.6[0-9]\.([0-9]{1,3})$/

  # Pour admin?, super? et manitou?,
  # cf. le fichier inst_options.rb
  # Rappel : Seuls les bits de 0 à 15 peuvent être utilisés par
  # le rest-site (la base). Les bits de 16 à 31 sont réservés à
  # l'application elle-même. Cf. le fichier .objet/site/config.rb
  # qui définit ces valeurs de l'application.

  def exist?
    return false if @id.nil?
    table.count(where:{id: id}) > 0
  end

  def guest?
    @id == nil
  end

  # Return true si le visiteur est une femme
  def femme?
    identified? && sexe == 'F'
  end
  # Return true si le visiteur est un homme
  def homme?
    !identified? || sexe == 'H'
  end

  def identified?
    (@id != nil) || google?
  end

  # Retourne true si l'user est à jour de ses paiements
  # Pour qu'il soit à jour, il faut qu'il ait un paiement qui
  # remonte à moins d'un an.
  def paiements_ok?
    return true   if google?  # Le bot de google
    return false  if @id.nil? # Un simple visiteur
    now = Time.now
    anprev = Time.new(now.year - 1, now.month, now.day).to_i
    last_abonnement && last_abonnement > anprev
  end
  alias :paiement_ok? :paiements_ok?
  alias :subscribed? :paiements_ok?

  # Cette propriété est mise à true lorsque l'user vient de
  # s'inscrire, qu'il devrait confirmer son mail, mais qu'il
  # doit payer son abonnement. On a mis alors `for_paiement` à
  # "1" dans ses variables de session, si qui lui permet de
  # passer outre la confirmation.
  # Noter que 'for_paiement' sera détruit après le paiement pour
  # obliger l'user à confirmer son mail.
  def for_paiement?
    @for_paiement ||= param(:for_paiement) == "1"
  end

  # Renvoie true si l'user est abonné depuis au moins +nombre_mois+
  # au site. False dans le cas contraire.
  # Par défaut 6 mois.
  def abonnement_recent?(nombre_mois = 6)
    return false if @id.nil? # pour guest
    return false if User::table_paiements.exist? == false
    return false if last_abonnement.nil?
    last_abonnement > (NOW.to_i - (30.5*nombre_mois).to_i.days)
  end

  def google?
    if @is_google === nil
      @is_google  = !!ip.match(REG_DNS_GOOGLE)
      debug "@is_google : #{@is_google.inspect}"
      if @is_google
        @pseudo     = "Google"
        @id         = 10
      end
    end
    @is_google
  end

end
