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
    when /liste? films/
      site.require_objet 'analyse'
      FilmAnalyse::films_in_table
    when /liste? filmodico/
      site.require_objet 'filmodico'
      Filmodico::films_in_table
    when /(nouvelle|new) page narration/
      console.require 'narration'
      goto_nouvelle_page_narration
    # PROGRAMME UN AN UN SCRIPT
    when /^unan /
      case line.downcase
      when "unan points"
        unan_affiche_points_sur_lannee
      when "unan état des lieux", "unan inventory"
        faire_etat_des_lieux_programme
      when "unan répare", "unan repare"
        reparation_programme_unan
      when "unan affiche (table pages cours)"
        afficher_table_pages_cours
      when "unan backup data (table pages cours)"
        backup_data_pages_cours
      when "unan destroy (table pages cours)"
        detruire_table_pages_cours
      when "unan retreive data (table pages cours)"
        retreive_data_pages_cours
      # ---------------------------------------------------------------------
      when "unan affiche (table exemples)"
        afficher_table_exemples
      when "unan backup data (table exemples)"
        backup_data_exemples
      when "unan destroy (table exemples)"
        detruire_table_exemples
      when "unan retreive data (table exemples)"
        retreive_data_exemples
      # ---------------------------------------------------------------------
      when "unan affiche (table absolute pdays)"
        afficher_table_absolute_pdays
      when "unan backup data (table absolute pdays)"
        backup_data_absolute_pdays
      when "unan destroy (table absolute pdays)"
        detruire_table_absolute_pdays
      when "unan retreive data (table absolute pdays)"
        retreive_data_absolute_pdays
      # ---------------------------------------------------------------------
      when "unan affiche (table absolute works)"
        afficher_table_absolute_works
      when "unan backup data (table absolute works)"
        backup_data_absolute_works
      when "unan destroy (table absolute works)"
        detruire_table_absolute_works
      when "unan retreive data (table absolute works)"
        retreive_data_absolute_works
      # ---------------------------------------------------------------------
      when "unan affiche (table projets)"
        afficher_table_projets
      when "unan backup data (table projets)"
        backup_data_projets
      when "unan destroy (table projets)"
        detruire_table_projets
      when "unan retreive data (table projets)"
        retreive_data_projets
      # ---------------------------------------------------------------------
      when "unan affiche (table programs)"
        afficher_table_programs
      when "unan backup data (table programs)"
        backup_data_programs
      when "unan destroy (table programs)"
        detruire_table_programs
      when "unan retreive data (table programs)"
        retreive_data_programs
      # ---------------------------------------------------------------------
      when "unan affiche (table questions)"
        afficher_table_questions
      when "unan backup data (table questions)"
        backup_data_questions
      when "unan destroy (table questions)"
        detruire_table_questions
      when "unan retreive data (table questions)"
        retreive_data_questions
      # ---------------------------------------------------------------------
      when "unan affiche (table quiz)"
        afficher_table_quiz
      when "unan backup data (table quiz)"
        backup_data_quiz
      when "unan destroy (table quiz)"
        detruire_table_quiz
      when "unan retreive data (table quiz)"
        retreive_data_quiz
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
