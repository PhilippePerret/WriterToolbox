# encoding: UTF-8
=begin
Extension des méthodes d'exécution des commandes console
=end
class SiteHtml
class Admin
class Console

  # Pour exécuter la line telle quelle
  def app_execute_as_is line

    case line.downcase
      # FILMODICO
    when /liste? films/
      site.require_objet 'analyse'
      FilmAnalyse::films_in_table
    when /liste? filmodico/
      site.require_objet 'filmodico'
      Filmodico::films_in_table
    when /^(nouveau|new) film$/
      if OFFLINE then "ERROR : seulement en ONLINE"
      else (redirect_to "filmodico/edit"); "" end
      # SCENODICO
    when /^(nouveau|new) mot$/
      if OFFLINE then "ERROR : seulement en ONLINE"
      else (redirect_to "scenodico/edit"); "" end
    when /^(état des lieux|etat des lieux|inventory) narration$/
      redirect_to "admin/inventory?in=cnarration"
      return ""
    when /(help|aide) livres narration/
      console.require 'narration'
      aide_pour_les_livres_narration
    when /^(nouvelle|new) page narration/
      console.require 'narration'
      goto_nouvelle_page_narration
    when /^(edit|éditer) page narration (.*?)$/
      console.require 'narration'
      edit_page_narration line.downcase.sub(/^edit page narration /, '')
    when /^(open|ouvre|ouvrir) page narration (.*)$/
      console.require 'narration'
      ouvrir_fichier_texte_page_narration line.sub(/^(ouvre|ouvrir) page narration /i,'')
    when /^(creer|create) (page|chapitre|chap|sous-chapitre|schap|sous_chapitre) narration (.*?)$/
      console.require 'narration'
      creer_page_ou_titre_narration line.sub(/^(creer|create) /,'')
    when /^(check|vérifier) pages narration out$/
      console.require 'narration'
      check_pages_narration_out_tdm
    when /^synchro(ni[zs]e)? (data)?base narration$/
      console.require 'narration'
      run_synchronize_database_narration
    when /^unan /
      # PROGRAMME UN AN UN SCRIPT
      console.require 'unan_unscript'
      case line.downcase
      when "unan points"
        unan_affiche_points_sur_lannee
      when "unan état des lieux", "unan inventory"
        faire_etat_des_lieux_programme
      when "unan répare", "unan repare"
        reparation_programme_unan
      when /^unan (afficher|affiche|backup data|destroy|retreive data) table (pages_cours|exemples|absolute_works|projets|absolute_pdays|programs|questions|quiz)$/
        # Cette condition capte toutes les commandes de type :
        # `Unan <action> table <table référence>`
        # qui permettent d'afficher le contenu d'une table, de faire un
        # backup, de détruire la table et de récupérer les données.
        splitted_line = line.downcase.split(' ')
        db_operation  = splitted_line[1]
        table_name    = splitted_line.last

        method_prefix = case db_operation
        when /afficher?/    then "afficher"
        when "backup"       then "backup_data"
        when /(destroy|detruire|kill)/      then "detruire"
        when "retreive" then "retreive_data"
        end

        # On invoque la méthode si elle existe
        method = "#{method_prefix}_table_#{table_name}".to_sym
        if respond_to? method
          send(method)
        else
          raise "La méthode `#{method}` est inconnu… Impossible de traiter la commande."
        end
        return ""
      else
        nil # pour chercher la commande autrement
      end

    else
      nil # pour chercher la commande autrement
    end
  end


  # Exécute une commande dont le dernier mot est
  # une variable
  # +sentence+  La commande avant la variable
  # +last_word+ Le dernier mot, donc la valeur de la variable
  def app_execute_as_last_is_variable sentence, last_word

    case sentence
    when /^pages narration niveau/i
      console.require 'narration'
      ( liste_pages_narration_of_niveau last_word )
    # ---------------------------------------------------------------------
    # PROGRAMME UN AN UN SCRIPT
    # ---------------------------------------------------------------------
    when /^unan (nouveau|nouvelle)/i
      ( goto_section "unan_new_#{last_word}" )
    when 'unan init program for'
      ( init_program_1an1script_for last_word )
    when 'detruire programmes de'
      ( detruire_programmes_de last_word )

    else
      nil # Pour essayer de trouver la commande autrement
    end
  end

  # Exécution comme une expression régulière propre à
  # l'application
  def app_execute_as_regular_sentence line
    if (found = line.match(/^balise (livre|film|mot|user) (.*?)(?: (ERB|erb))?$/).to_a).count > 0
      ( main_traitement_balise found[1..-1] )
    elsif ( found = line.match(/^set benoit to pday ([0-9]+)(?: with (\{(?:.*?)\}))?$/).to_a).count > 0
      (site.folder_lib_optional + 'console/pday_change/main.rb').require
      pday_indice = found[1].to_i
      params = found[2]
      params = eval(params) unless params.nil?
      # debug "--> User::get(2).change_pday(pday_indice=#{pday_indice}, params=#{params.inspect})"
      site.require_objet 'unan'
      Unan::require_module 'quiz'
      User::get(2).change_pday pday_indice, params
    else
      return false # pour chercher la commande autrement
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
