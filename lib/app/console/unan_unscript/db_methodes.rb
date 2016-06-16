# encoding: UTF-8
raise_unless_admin

require 'pstore'

class SiteHtml
class Admin
class Console

  def init_unan
    site.require_objet 'unan'
  end

  # ---------------------------------------------------------------------
  # Méthodes de récupération des données
  # (qui ont été backupées dans des PStores)
  def retreive_data_table_pages_cours
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retrieve_data_from_all( 'unan_cold.db', 'page_cours', proc_modif )
  end

  def retreive_data_table_exemples
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    # La table courante
    retrieve_data_from_all('unan_cold.db', 'exemples', proc_modif)
  end
  def retreive_data_table_absolute_works
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      # debug "data work : #{data.inspect}"
      data = data_init.dup
      data # doit être retourné (ou nil)
    end
    retrieve_data_from_all('unan_cold.db', 'absolute_works', proc_modif)
  end
  def retreive_data_absolute_pdays
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retrieve_data_from_all('unan_cold.db', 'absolute_pdays', proc_modif)
  end
  def retreive_data_table_projets
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retrieve_data_from_all('unan_hot.db', 'projets', proc_modif)
  end
  def retreive_data_table_questions
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retrieve_data_from_all('unan_cold.db', 'questions', proc_modif)

  end
  def retreive_data_table_quiz
    proc_modif = Proc::new do |data_init|
      # ICI LE TRAITEMENT DES DONNÉES POUR INSÉRER DANS LA
      # NOUVELLE TABLE
      data = data_init.dup
      data
    end
    retrieve_data_from_all('unan_cold.db', 'quiz', proc_modif)
  end


  #
  # /Fin des méthodes de récupération des data
  # ---------------------------------------------------------------------



  def backup_data_table_exemples
    backup_data_from_all('unan_cold.db', 'exemples')
  end
  def backup_data_table_questions
    backup_data_from_all('unan_cold.db', 'questions')
  end
  def backup_data_table_quiz
    backup_data_from_all('unan_cold.db', 'quiz')
  end
  def backup_data_table_absolute_pdays
    backup_data_from_all('unan_cold.db', 'absolute_pdays')
  end
  def backup_data_table_pages_cours
    backup_data_from_all('unan_cold.db', 'pages_cours')
  end
  def backup_data_table_projets
    backup_data_from_all('unan_hot.db', 'projets')
  end
  def backup_data_table_absolute_works
    backup_data_from_all('unan_cold.db', 'absolute_works')
  end

  def destruction_impossible
    @destruction_impossible ||= "Impossible de détruire la table des %{choses} en ONLINE (trop dangereux)."
  end
  def detruire_table_exemples
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'exemples';")
      "Table des exemples détruite avec succès."
    else
      destruction_impossible % {choses: "exemples"}
    end
  end
  def detruire_table_questions
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'questions';")
      "Table des questions détruite avec succès."
    else
      destruction_impossible % {choses: "questions"}
    end
  end
  def detruire_table_quiz
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'quiz';")
      "Table des quiz détruite avec succès."
    else
      destruction_impossible % {choses: "quiz"}
    end
  end

  def detruire_table_pages_cours
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'pages_cours';")
      "Table des pages de cours détruite avec succès."
    else
      destruction_impossible % {choses: "pages de cours"}
    end
  end

  def afficher_table_exemples
    init_unan
    show_table Unan::table_exemples
  end
  def afficher_table_questions
    init_unan
    show_table Unan::table_questions
  end
  def afficher_table_quiz
    init_unan
    show_table Unan::table_quiz
  end

  def afficher_table_pages_cours
    init_unan
    show_table Unan::Program::PageCours::table_pages_cours
  end

  def afficher_table_absolute_pdays
    init_unan
    show_table Unan::table_absolute_pdays
  end
  def detruire_table_absolute_pdays
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'absolute_pdays';")
      "Tables des données jours-programme absolus détruite à jamais."
    else
      "Impossible de détruire la table des données absolues\n# des jours-programme ONLINE"
    end
  end


  def afficher_table_absolute_works
    init_unan
    show_table Unan::table_absolute_works
  end

  def detruire_table_absolute_works
    if OFFLINE
      init_unan
      Unan::database.execute("DROP TABLE IF EXISTS 'absolute_works';")
      "Tables des données travaux absolus détruite à jamais."
    else
      "Impossible de détruire la table des données absolues\n# des travaux ONLINE"
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
