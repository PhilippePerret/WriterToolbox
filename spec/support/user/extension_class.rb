# encoding: UTF-8

class User

  # Définir son grade forum
  def test_set_grade
    raise 'On ne peut pas encore définir le grade forum par ce biais'
  end

  def set_simple_inscrit
    test_set_state :inscrit, sexe = 'H'
  end
  def set_simple_inscrite
    test_set_state :inscrit, sexe = 'F'
  end
  def set_subscribed
    test_set_state :subscribed
  end

  # Définir son état (inscrit, abonné, unanunscript)
  def test_set_state state, genre = 'H'
    self.sexe == genre || set(sexe: genre)
    drequest = {where: {user_id: id}}
    case state
    when :inscrit
      User.table_paiements.delete(drequest)
      User.table_autorisations.delete(drequest)
      test_destroy_from_unan
    when :subscribed
      User.table_paiements.count(drequest) > 0      || test_create_paiement
      User.table_autorisations.count(drequest) > 0  || test_create_autorisation
      test_destroy_from_unan
    when :unanunscript
      raise "On ne peut pas encore mettre #{self.pseudo} en auteur UNAN par ce biais."
    else
      raise "L'état #{state} est inconnu… #{pseudo} ne peut pas être passé dans cet état."
    end
  end

  # Quand il faut détruire totalement l'abonnement de
  # l'utilisateur du programme UN AN
  def test_destroy_from_unan
    site.require_objet 'unan'
    Unan.table_programs.delete(where: {auteur_id: self.id})
    Unan.table_projets.delete(where: {auteur_id: self.id})
    # Détruire les trois tables dans la base `boite-a-outils_users_tables`
    liste_tables =
      ['pages_cours', 'quiz', 'works'].collect do |tbl|
        tbl_name = "unan_#{tbl}_#{id}"
      end.join(', ')
    request = "DROP TABLE IF EXISTS #{liste_tables};"
    SiteHtml::DBM_BASE.execute('users_tables', request)
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
