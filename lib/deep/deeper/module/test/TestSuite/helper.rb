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
      " | #{online? ? 'ONLINE' : 'OFFLINE'}" +
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
    nombre_total = {success: 0, failure: 0}
    messages_str = {success: "", failure: ""}

    nombre_total_success  = 0
    nombre_total_failures = 0
    success_messages = String::new
    failure_messages = String::new

    @itestfile = 0

    # Boucle sur chaque fichier-test
    test_files.each do |testfile|

      nombre = {
        success:  testfile.success_tests.count,
        failure:  testfile.failure_tests.count
      }
      nombre_total[:success] += nombre[:success]
      nombre_total[:failure] += nombre[:failure]

      # Si le fichier n'a aucun succès ni aucune failure, c'est
      # qu'aucun test n'a été joué. => On le passe.
      next if (nombre[:success] + nombre[:failure]) == 0

      # Est-ce en mode verbeux ou quiet ? Cela peut être
      # déterminé par :
      #   - les options générales de la ligne de commande
      #   en utilisant `-q` ou `-v`,
      #   - les options du fichier lui-même (en utilisant
      #     `verbose` ou `quiet` à l'intérieur du fichier-test,
      #       hors méthode de test)
      #   - les options du test-méthode en utilisant
      #     `verbose` ou `quiet` à l'intérieur de la méthode
      #     de test.

      # La ligne principale décrivant le fichier courant.
      div_filepath = "#{@itestfile += 1}- #{testfile.path}".in_div(class:'pfile')

      @icase = 0
      filetest_messages = { failure: nil, success: nil }
      [:failure, :success].each do |ktype|
        filetest_messages[ktype] = messages_of_tmethods_of_tfile( testfile, ktype )
        # On ajoute les messages, sauf s'il sont vides
        if nombre[ktype] > 0
          messages_str[ktype] += (div_filepath + filetest_messages[ktype]).in_div(class:'atests').in_div(class:"tfile #{ktype[0..2]}")
        end
      end

    end #/Fin de boucle sur chaque fichier-test

    # Définir les variables d'instance qui vont contenir les
    # valeurs à prendre en compte
    @nombre_failures = nombre_total[:failure]
    @nombre_success  = nombre_total[:success]

    # Renseigner le nombre total de tests
    infos[:nombre_tests] = nombre_total[:success] + nombre_total[:failure]

    @detail_failures = if nombre_total[:failure] > 0
      "Failures".in_h4(class:'red') + messages_str[:failure]
    else
      ""
    end
    @detail_success = if nombre_total[:success] > 0
      "Success".in_h4(class:'green') + messages_str[:success]
    else
      ""
    end
  end

  def messages_of_tmethods_of_tfile tfile, type
    tfile.send("#{type}_tests".to_sym).collect do |tmethod|
      verbose = if type == :failure
        true
      else
        ( tmethod.verbose? || tmethod.quiet? === false ) ||
        ( tfile.verbose?   || tfile.quiet? === false )   ||
        ( verbose?         || quiet? === false )
      end
      infos[:nombre_cas] += tmethod.messages_count
      c = tmethod.full_libelle_output( @itestfile, @icase += 1 )
      c << tmethod.messages_output if verbose
      c
    end.join('')
  end

end #/TestSuite
end #/SiteHtml
