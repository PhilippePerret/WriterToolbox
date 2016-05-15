# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end

class SiteHtml
class TestSuite

  def display_resultat
    log resultat
  end

  def resultat
    @resultat ||= begin

      # Construire les éléments d'affichage
      details_test

      color = nombre_failures == 0 ? 'green' : 'red'
      s_failures = nombre_failures > 1 ? "s" : ""
      resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} success".in_span(class: color)

      (
        resume            +
        @detail_failures  +
        @detail_success   +
        disp_infos_test
      )
    end
  end

  def disp_infos_test
    s_tests = infos[:nombre_tests] > 1 ? 's' : ''
    s_files = infos[:nombre_files] > 1 ? 's' : ''
    laps = (infos[:end_time] - infos[:start_time]).round(4)
    "<hr>" + (
      "#{infos[:nombre_files]} fichier#{s_files}" +
      " | #{infos[:nombre_tests]} test#{s_tests}"+
      " | #{infos[:nombre_cas]} cas"+
      " | durée : #{laps}" +
      " | folder: #{folder_test_path}" +
      " | "
    ).in_div(id:'test_infos')
  end

  def infos
    @infos ||= {
      start_time:   nil,
      end_time:     nil,
      nombre_files: 0, # Nombre de fichiers
      nombre_tests: 0,
      nombre_cas:   0
    }
  end

  def nombre_failures;  @nombre_failures end
  def nombre_success;   @nombre_success  end

  # Méthode créant l'affichage des succès et des failures
  # on passant fichier test après fichier test
  def details_test
    nombre_total_success  = 0
    nombre_total_failures = 0
    success_messages = String::new
    failure_messages = String::new

    itestfile = 0

    # Boucle sur chaque fichier-test
    test_files.each do |testfile|

      nombre_success  = testfile.success_tests.count
      nombre_failures = testfile.failure_tests.count
      nombre_total_success  += nombre_success
      nombre_total_failures += nombre_failures

      # Si le fichier n'a aucun succès ni aucune failure, c'est
      # qu'aucun test n'a été joué. => On le passe.
      next if (nombre_success + nombre_failures) == 0

      # La ligne principale décrivant le fichier courant.
      div_filepath = "#{itestfile += 1}- #{testfile.path}".in_div(class:'pfile')

      icase = 0

      filetest_failure_messages = testfile.failure_tests.collect do |tmethod|
        infos[:nombre_cas] += tmethod.messages_count
        tmethod.full_libelle_output( itestfile, icase += 1 ) +
        tmethod.messages_output
      end.join('')

      filetest_success_messages = testfile.success_tests.collect do |tmethod|
        infos[:nombre_cas] += tmethod.messages_count
        tmethod.full_libelle_output( itestfile, icase += 1 ) +
        tmethod.messages_output
      end.join('')

      # On ajoute les messages, sauf s'il sont vides
      if nombre_success > 0
        success_messages += (div_filepath + filetest_success_messages).in_div(class:'atests').in_div(class:'tfile suc')
      end
      if nombre_failures > 0
        failure_messages += (div_filepath + filetest_failure_messages).in_div(class:'atests').in_div(class:'tfile err')
      end


    end #/Fin de boucle sur chaque fichier-test

    # Définir les variables d'instance qui vont contenir les
    # valeurs à prendre en compte
    @nombre_failures = nombre_total_failures
    @nombre_success  = nombre_total_success

    # Renseigner le nombre total de tests
    infos[:nombre_tests] = nombre_total_success + nombre_total_failures

    @detail_failures = if nombre_total_failures > 0
      "Failures".in_h4(class:'red') + failure_messages
    else
      ""
    end
    @detail_success = if nombre_total_success > 0
      "Success".in_h4(class:'green') + success_messages
    else
      ""
    end

  end
end #/TestSuite
end #/SiteHtml
