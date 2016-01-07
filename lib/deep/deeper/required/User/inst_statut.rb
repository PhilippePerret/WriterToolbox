# encoding: UTF-8
=begin
Méthodes de statut pour l'utilisateur (courant ou autre)
=end
class User

  def admin?
    @id == 1
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
    @id != nil
  end

  # Retour true si l'user est à jour de son abonnement
  def subscribed?

  end

  # Retourne true si l'user est à jour de ses paiements
  # Pour qu'il soit à jour, il faut qu'il ait un paiement qui
  # remonte à moins d'un an.
  def paiements_ok?
    return false if @id.nil? # Un simple visiteur
    now = Time.now
    anprev = Time.new(now.year - 1, now.month, now.day).to_i
    where = "user_id = #{id} AND created_at > #{anprev} AND objet_id = 'ABONNEMENT'"
    User::table_paiements.count(where:where) != 0
  end
  alias :paiement_ok? :paiements_ok?
  alias :subscribed? :paiements_ok?

  # Renvoie true si l'user est abonné depuis au moins +nombre_mois+
  # au site. False dans le cas contraire.
  # Par défaut 6 mois.
  def abonnement_recent?(nombre_mois = 6)
    return false if @id.nil? # pour guest
    return false if User::table_paiements.exist? == false
    last_paiement_abonnement = User::table_paiements.select(where:"user_id = #{id} AND objet_id = 'ABONNEMENT'", order:"created_at DESC", limit:1).values.first
    return false if last_paiement_abonnement.nil?
    last_paiement_abonnement > (NOW - (30.5*nombre_mois).days)
  end

  # {Fixnum} Date (timestamp) de prochain paiement
  # Noter que cette méthode, pour le moment, ne doit être appelée
  # que si l'user a déjà procédé à un paiement.
  def next_paiement
    @next_paiement ||= begin
      raise "ID devrait être défini pour checker le paiement" if @id.nil?
      last_paiement = User::table_paiements.select(where:{user_id: id, objet_id: "ABONNEMENT"}, order:"created_at DESC", limit:1, colonnes:[:created_at]).values.first[:created_at]
      dlast = Time.at(last_paiement)
      Time.new(dlast.year + 1, dlast.month, dlast.day).to_i
    end
  end
end
