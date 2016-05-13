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

      color = failures.empty? ? 'green' : 'red'
      s_failures = nombre_failures > 1 ? "s" : ""
      resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} succès".in_span(class: color)

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
      " | durée : #{laps}" +
      " | folder: #{folder_test_path}" +
      " | #{infos[:nombre_files]} fichier#{s_files}" +
      " | "
    ).in_div(id:'test_infos')
  end

  def infos
    @infos ||= {
      start_time:   nil,
      end_time:     nil,
      nombre_files: 0, # Nombre de fichiers
      nombre_tests: 0
    }
  end

  def nombre_failures;  @nombre_failures end
  def nombre_success;   @nombre_success  end

  # Méthode créant l'affichage des succès et des failures
  # on passant fichier test après fichier test
  def details_test
    nombre_success  = 0
    nombre_failures = 0
    success_messages = String::new
    failure_messages = String::new

    itestfile = 0

    test_files.each do |testfile|

      nombre_success  += testfile.success_atests.count
      nombre_failures += testfile.failure_atests.count

      div_filepath = "#{itestfile += 1}- #{testfile.path}".in_div(class:'pfile')

      icase = 0
      filetest_success_messages = testfile.success_atests.collect do |atest|
        "#{itestfile}.#{icase += 1} - #{atest.libelle}".in_div(class:'tlib') +
        atest.messages.collect do |itf, itt, message|
          # Rappel :  itf est l'instance TestFile
          #           itt est l'instance Atest
          message.in_div(class:"mess")
        end.join("\n")
      end.join('').in_div(class:'atests')

      icase
      filetest_failure_messages = testfile.failure_atests.collect do |atest|
        nombre_messages = atest.messages.count
        imessage = 0
        "#{itestfile}.#{icase += 1} - #{atest.libelle}".in_div(class:'tlib') +
        atest.messages.collect do |itf, itt, message|
          # Rappel :  itf est l'instance TestFile
          #           itt est l'instance Atest
          imessage += 1
          css = imessage == nombre_messages ? 'err' : 'suc'
          message.in_div(class:"mess #{css}")
        end.join("\n")
      end.join('').in_div(class:'atests')

      # On ajoute les messages, sauf s'il sont vides
      unless filetest_success_messages.empty?
        success_messages += (div_filepath + filetest_success_messages).in_div(class:'tfile suc')
      end
      unless filetest_failure_messages.empty?
        failure_messages += (div_filepath + filetest_failure_messages).in_div(class:'tfile err')
      end


    end

    # Définir les variables d'instance qui vont contenir les
    # valeurs à prendre en compte
    @nombre_failures = nombre_failures
    @nombre_success  = nombre_success

    @detail_failures = if nombre_failures > 0
      "Failures".in_h4(class:'red') + failure_messages
    else
      ""
    end
    @detail_success = if nombre_success > 0
      "Succès".in_h4(class:'green') + success_messages
    else
      ""
    end

  end

  # def detail_failures
  #   return "" if nombre_failures == 0
  #   c = ""
  #
  #   c += failures.collect do |ifailure, tfile, atest|
  #     div = "#{ifailure}. #{tfile.path}".in_div(class:'pfile red')
  #     # Pour ne mettre que le dernier en erreur
  #     message_count = atest.messages.count
  #     imessage = 0
  #     list_messages = atest.messages.collect do |itf, itt, message|
  #       # Rappel :  itf est l'instance TestFile
  #       #           itt est l'instance Atest
  #       imessage += 1
  #       message.in_div(class:'mess ' + (imessage == message_count ? 'err' : 'suc'))
  #     end.join('')
  #
  #     (
  #       div +
  #       "#{ifailure}.#{icase += 1} - #{atest.libelle}".in_div(class:'tname err') +
  #       list_messages
  #     ).in_div(class:'atest err')
  #     # div
  #   end.join("\n")
  # end
  # def detail_success
  #   return "" if nombre_success == 0
  #   icase = 0
  #   c = ""
  #   c << "Succès".in_h4(class:'green') +
  #   c += success.collect do |isuccess, tfile, atest|
  #     div = "#{isuccess}. #{tfile.path}".in_div(class:'pfile')
  #     (
  #       div +
  #       "#{isuccess}.#{icase += 1} #{atest.libelle}".in_div(class:'tname suc') +
  #       atest.messages.collect do |itf, itt, message|
  #         # Rappel :  itf est l'instance TestFile
  #         #           itt est l'instance Atest
  #         message.in_div(class:'mess suc')
  #       end.join('')
  #     ).in_div(class:'atest suc')
  #     # div
  #   end.join("\n")
  # end

end #/TestSuite
end #/SiteHtml
