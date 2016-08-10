# encoding: UTF-8

class User

  # Définir son grade forum
  def set_grade
    raise 'On ne peut pas encore définir le grade forum par ce biais'
  end

  def set_simple_inscrit
    set_state :inscrit
  end
  def set_subscribed
    set_state :subscribed
  end

  # Définir son état (inscrit, abonné, unanunscript)
  def set_state state
    drequest = {where: {user_id: id}}
    case state
    when :inscrit
      User.table_paiements.delete(drequest)
      User.table_autorisations.delete(drequest)
    when :subscribed
      User.table_paiements.count(drequest) > 0      || test_create_paiement
      User.table_autorisations.count(drequest) > 0  || test_create_autorisation
    when :unanunscript
      raise "On ne peut pas encore mettre #{self.pseudo} en auteur UNAN par ce biais."
    else
      raise "L'état #{state} est inconnu… #{pseudo} ne peut pas être passé dans cet état."
    end

  end

  def test_create_paiement objet = 'ABONNEMENT', montant = site.tarif
    User.table_paiements.insert(
      user_id:      self.id,
      objet_id:     objet,
      montant:      montant,
      facture:      'EC-38P44270A5110' + (rand(10000)).rjust(4,'0'),
      created_at:   NOW - rand(20000)
    )
  end
  def test_create_autorisation from_time = NOW, nombre_jours = 366, raison = 'ABONNEMENT'
    User.table_autorisations.insert(
      user_id:        self.id,
      start_time:     from_time,
      end_time:       from_time + nombre_jours.days,
      nombre_jours:   nombre_jours,
      privileges:     0,
      raison:         raison,
      created_at:     from_time,
      updated_at:     from_time
    )
  end
end # /User
