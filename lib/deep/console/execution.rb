# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def execute_code

    lines.each do |line|

      # On marque la ligne pour pouvoir savoir ce qui a produit
      # le résultat
      log line, :code

      # On ajoute toujours la ligne au code qui sera ré-affiché dans
      # la console
      add_code line

      #
      # DÈS QU'UNE LIGNE EST AJOUTÉE, IL FAUT RENSEIGNER
      # LE FICHIER help.rb DE CONSOLE
      #
      # On exécute la ligne telle quelle
      res = execute_as_is( line )
      # On exécute la ligne de type dernier mot variable
      res ||= execute_as_last_is_variable( line )
      # En dernier recours, on exécute la ligne comme du code
      # ruby
      res ||= execute_as_ruby( line )

      res = case res
      when String   then res
      when NilClass then "-- aucun retour --"
      else res.inspect
      end
      add_code "##{'-'*50}\n# => " + res + "\n##{'-'*50}"

    end

  rescue Exception => e
    error e.message
    debug "--- ERREUR : #{e.message}"
    debug e.backtrace.join("\n")
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'analyse de la phrase
  # ---------------------------------------------------------------------

  # Analyse de la ligne telle quelle
  def execute_as_is line
    case line

    when "vide table paiements", "vider table paiements"
      vide_table_paiements
    when "remove table paiements"
      remove_table_paiements


    when "Unan état des lieux", "Unan inventory"
      faire_etat_des_lieux_programme

    when "Unan répare", "Unan repare"
      reparation_programme_unan

    # ---------------------------------------------------------------------

    when "Unan affiche (table pages cours)"
      afficher_table_pages_cours
    when "Unan backup data (table pages cours)"
      backup_data_pages_cours
    when "Unan destroy (table pages cours)"
      detruire_table_pages_cours
    when "Unan retreive data (table pages cours)"
      retreive_data_pages_cours

    # ---------------------------------------------------------------------

    when "Unan affiche (table absolute pdays)"
      afficher_table_absolute_pdays
    when "Unan backup data (table absolute pdays)"
      backup_data_absolute_pdays
    when "Unan destroy (table absolute pdays)"
      detruire_table_absolute_pdays
    when "Unan retreive data (table absolute pdays)"
      retreive_data_absolute_pdays

    when "Unan affiche (table absolute works)"
      afficher_table_absolute_works
    when "Unan backup data (table absolute works)"
      backup_data_absolute_works
    when "Unan destroy (table absolute works)"
      detruire_table_absolute_works
    when "Unan retreive data (table absolute works)"
      retreive_data_absolute_works

    # ---------------------------------------------------------------------

    when "Unan affiche (table projets)"
      affiche_table_projets
    when "Unan backup data (table projets)"
      backup_data_projets
    when "Unan destroy (table projets)"
      detruire_table_projets
    when "Unan retreive data (table projets)"
      retreive_data_projets

    # ---------------------------------------------------------------------

    when "Unan affiche (table programs)"
      affiche_table_programs
    when "Unan backup data (table programs)"
      backup_data_programs
    when "Unan destroy (table programs)"
      detruire_table_programs
    when "Unan retreive data (table programs)"
      retreive_data_programs

    # ---------------------------------------------------------------------

    when "Unan affiche (table questions)"
      affiche_table_questions
    when "Unan backup data (table questions)"
      backup_data_questions
    when "Unan destroy (table questions)"
      detruire_table_questions
    when "Unan retreive data (table questions)"
      retreive_data_questions

    # ---------------------------------------------------------------------

    when "Unan affiche (table quiz)"
      affiche_table_quiz
    when "Unan backup data (table quiz)"
      backup_data_quiz
    when "Unan destroy (table quiz)"
      detruire_table_quiz
    when "Unan retreive data (table quiz)"
      retreive_data_quiz

    # ---------------------------------------------------------------------

    when "list gels"
      affiche_liste_des_gels

    else
      nil # pour essayer autrement
    end
  end

  # On exécute la ligne comme si son dernier terme était
  # une variable
  def execute_as_last_is_variable line
    words = line.split(' ').reject{|m| m.strip == ""}
    last_word = words.pop
    sentence  = words.join(' ')
    # debug "sentence : '#{sentence}'"
    # debug "last word : '#{last_word}'"

    # On corrige last_word qui peut commencer par des
    # guillemets simples ou doubles
    if last_word.match(/^['"](.*?)['"]$/)
      last_word = last_word[1..-2].strip
    end

    case sentence
    when 'Unan init program for'
      init_program_1an1script_for( last_word )
    when 'detruire programmes de'
      detruire_programmes_de( last_word )
    when 'affiche table'
      montre_table( last_word )
    when 'gel'
      gel last_word
    when 'degel'
      degel last_word
    else
      nil
    end
  end

  # Dans le cas où la ligne n'a pas pu être interprétée avant,
  # on essaie de l'exécuter telle quelle
  def execute_as_ruby line
    begin
      res = eval(line)
      "#{res.inspect}"
      # log "---> #{res.inspect}"
    rescue Exception => e
      error "Line injouable : `#{line}`"
      "### LIGNE INCOMPRÉHENSIBLE ### #{e.message}"
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes utilisables
  # ---------------------------------------------------------------------
  def vide_table_paiements

    if OFFLINE
      User::table_paiements.pour_away
      if User::table_paiements.count == 0
        "Table des paiements vidée avec succès"
      else
        "Bizarrement, la table des paiements ne semble pas vide…"
      end
    else
      "Impossible de vider la table des paiements en ONLINE"
    end

  end

  def remove_table_paiements
    if OFFLINE
      User::table_paiements.remove
      "Table des paiements détruite avec succès."
    else
      "Impossible de détruire la table des paiements en ONLINE. On perdrait toutes les données."
    end
  end

  def montre_table table_ref
    db_name, table_name = table_ref.split('.')
    db_path = "./database/data/#{db_name}.db"
    raise "La base `#{db_path}` est introuvable…" unless File.exist?(db_path)
    table = BdD::new(db_path).table(table_name)
    raise NotFatalError, "La table `table_name` est inconnue dans `#{db_path}`…" unless table.exist?
    # Sinon, on peut afficher la table
    show_table table
  end

  def detruire_programmes_de uref
    raise "Impossible en ONLINE, désolé" if ONLINE
    u = if uref.numeric?
      User::get(uref.to_i)
    else
      User::get_by_pseudo(uref)
    end

    raise "Impossible d'obtenir l'user avec la référence #{uref}" if u.nil?

    # On charge tout ce qui concerne Unan, on en aura
    # besoin plus bas (pour les bases de données)
    site.require_objet 'unan'

    # Destruction des paiements "1UN1SCRIPT" de l'user
    where = "user_id = #{u.id} AND objet_id = '1AN1SCRIPT'"
    nombre_paiements = User::table_paiements.count(where:where)
    User::table_paiements.delete(where:where)

    # Destruction de son dossier dans database/data/unan/user
    with_dossier_db = u.folder_data.exist? ? "détruit" : "inexistant"
    u.folder_data.remove if u.folder_data.exist?

    # Destruction de ses programmes dans la table
    where = "auteur_id = #{u.id}"
    nombre_programmes = Unan::table_programs.count(where:where)
    nombre_projets    = Unan::table_projets.count(where:where)
    Unan::table_programs.delete(where:where)
    # Destruction de ses projets dans la table
    Unan::table_projets.delete(where:where)

    "Destruction de tous les programmes de #{u.pseudo} opérée avec succès\n# Nombre paiements détruits : #{nombre_paiements}\n# Dossier database : #{with_dossier_db}\n# Nombre programmes détruits : #{nombre_programmes}\n# Nombre projets détruits : #{nombre_projets}"
  end

end #/Console
end #/Admin
end #/SiteHtml
