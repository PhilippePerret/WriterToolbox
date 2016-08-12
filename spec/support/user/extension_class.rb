# encoding: UTF-8

class User

  # Définir son grade forum
  def test_set_grade
    raise 'On ne peut pas encore définir le grade forum par ce biais'
  end

  # +args+
  #   :pday       Le jour auquel on doit passer l'user
  #   :rythme     Le rythme auquel on doit le passer
  #   :retards    La liste des 0-9 pour les retards de chaque jour
  #   :verbose    Si true, on affiche tout le travail qui est fait
  #
  def set_auteur_unanunscript args = nil
    test_set_state :unanunscript, self.sexe, args
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
  def test_set_state state, genre = 'H', args = nil
    args ||= Hash.new
    self.sexe == genre || set(sexe: genre)
    # Dans tous les cas, même lorsqu'on doit le transformer en
    # auteur unan un script, on le retire
    test_destroy_from_unan
    drequest = {where: {user_id: id}}
    case state
    when :inscrit
      User.table_paiements.delete(drequest)
      User.table_autorisations.delete(drequest)
    when :subscribed
      User.table_paiements.count(drequest) > 0      || test_create_paiement
      User.table_autorisations.count(drequest) > 0  || test_create_autorisation
    when :unanunscript
      pour_test_make_auteur_unan args
    else
      raise "L'état #{state} est inconnu… #{pseudo} ne peut pas être passé dans cet état."
    end
  end

  def pour_test_make_auteur_unan args
    site.require_objet 'unan'
    (Unan.folder_modules + 'signup_user.rb').require
    self.signup_program_uaus

    args[:pday] ||= 1
    verbose = !!args[:verbose]

    verbose && puts("\n\nCRÉATION DE L'AUTEUR PROGRAMME UNAN #{pseudo}")

    # Faut-il le mettre déjà à un jour-programme particulier ?
    # Noter que s'il faut le passer à un jour particulier, il
    # faut régler sa date de démarrage pour que ça corresponde
    xieme_jour = args[:pday]
    verbose && puts("Jour-programme choisi : #{xieme_jour}")
    args[:rythme] ||= self.program.rythme
    verbose && puts("Rythme du programme : #{args[:rythme]}")
    r     = args[:rythme]
    coef  = r.to_f / 5.0
    xieme_jour_reel = (xieme_jour.to_f * coef).to_i
    verbose && puts("#{pseudo} est à son #{xieme_jour_reel}e jour réel")
    demarrage_programme = NOW - xieme_jour_reel
    verbose && puts("Démarrage du programme UN AN mis à #{demarrage_programme.as_human_date(true, true, ' ', 'à')}")
    args[:retards] ||= '0'*(xieme_jour - 1)
    verbose && puts("Retards définis : #{args[:retards]}")
    self.program.set(
      created_at:         demarrage_programme,
      updated_at:         NOW,
      rythme:             args[:rythme],
      current_pday:       xieme_jour,
      current_pday_start: NOW - 3.hours,
      retards:            args[:retards] # Aucun retard
      )

    # Le paiement fait pour acheter le module
    data_paiement = {
      user_id:    self.id,
      objet_id:   '1AN1SCRIPT',
      montant:    Unan.tarif,
      facture:    'EC-38P44270A5110'+(rand(10000).to_s.rjust(4,'0')),
      created_at:  demarrage_programme
    }
    site.dbm_table(:cold, 'paiements').insert(data_paiement)
    verbose && puts("Création du paiement pour #{pseudo} (#{Unan.tarif})")

    # Il faut ajouter une autorisation
    dauto = {
      user_id:        self.id,
      start_time:     demarrage_programme,
      end_time:       demarrage_programme + ((366+365).days),
      nombre_jours:   366+365,
      raison:         'UNANUNSCRIPT',
      created_at:     demarrage_programme,
      updated_at:     demarrage_programme
    }
    User.table_autorisations.insert(dauto)
    verbose && puts("Création de l'autorisation pour #{pseudo}.")

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
