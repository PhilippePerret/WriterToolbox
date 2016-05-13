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
      color = failures.empty? ? 'green' : 'red'
      s_failures = nombre_failures > 1 ? "s" : ""
      resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} succès".in_span(class: color)

      (
        resume          +
        detail_failures +
        detail_success  +
        disp_infos_test
      )
    end
  end

  def disp_infos_test
    s_tests = infos[:nombre_tests] > 1 ? 's' : ''
    s_files = infos[:nombre_files] > 1 ? 's' : ''
    laps = (infos[:end_time] - infos[:start_time]).round(4)
    "<hr>" + (
      "#{infos[:nombre_tests]} test#{s_tests}"+
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

  def nombre_failures;  @nombre_failures  ||= failures.count  end
  def nombre_success;   @nombre_success   ||= success.count   end

  def detail_failures
    return "" if nombre_failures == 0
    c = ""
    c << "Failures".in_h4(class:'red') +
    c += failures.collect do |ifailure, tfile, atest|
      div = "#{ifailure}. #{tfile.path}".in_div(class:'pfile red')
      # Pour ne mettre que le dernier en erreur
      message_count = atest.messages.count
      imessage = 0
      list_messages = atest.messages.collect do |itf, itt, message|
        # Rappel :  itf est l'instance TestFile
        #           itt est l'instance Atest
        imessage += 1
        message.in_div(class:'mess ' + (imessage == message_count ? 'err' : 'suc'))
      end.join('')

      (
        div +
        "#{ifailure}.#{icase += 1} - #{atest.libelle}".in_div(class:'tname err') +
        list_messages
      ).in_div(class:'atest err')
      # div
    end.join("\n")
  end
  def detail_success
    return "" if nombre_success == 0
    icase = 0
    c = ""
    c << "Succès".in_h4(class:'green') +
    c += success.collect do |isuccess, tfile, atest|
      div = "#{isuccess}. #{tfile.path}".in_div(class:'pfile')
      (
        div +
        "#{isuccess}.#{icase += 1} #{atest.libelle}".in_div(class:'tname suc') +
        atest.messages.collect do |itf, itt, message|
          # Rappel :  itf est l'instance TestFile
          #           itt est l'instance Atest
          message.in_div(class:'mess suc')
        end.join('')
      ).in_div(class:'atest suc')
      # div
    end.join("\n")
  end

end #/TestSuite
end #/SiteHtml
